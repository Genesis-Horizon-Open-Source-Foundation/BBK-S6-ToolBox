::修改: n

::call clean twrpfactoryreset
::           twrpformatdata
::           formatfat32       [name:分区名 path:分区路径]  [卷标(可选,不填则不设置)]
::           formatntfs        [name:分区名 path:分区路径]  [卷标(可选,不填则不设置)]
::           formatexfat       [name:分区名 path:分区路径]  [卷标(可选,不填则不设置)]
::           formatext4        [name:分区名 path:分区路径]  [卷标(可选,不填则不设置)]
::           qcedl             分区名                      端口号(数字或auto)        firehose完整路径(可选,不填不发送)


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%







:QCEDL
SETLOCAL
set logger=clean.bat-qcedl
::接收变量
set parname=%args2%& set port=%args3%& set fh=%args4%
call log %logger% I 接收变量:parname:%parname%.port:%port%.fh:%fh%
:QCEDL-1
::如果端口号为auto或空则自动检查端口
if "%port%"=="auto" call chkdev qcedl 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcedl%
if "%port%"=="" call chkdev qcedl 1>nul
if "%port%"=="" set port=%chkdev__port__qcedl%
::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% auto
::读取设备信息
call info qcedl %port%
::回读, 解析分区表文件
if exist %tmpdir%\ptanalyse rd /s /q %tmpdir%\ptanalyse 1>>%logfile% 2>&1
md %tmpdir%\ptanalyse 1>>%logfile% 2>&1
set num=0
:QCEDL-2
if "%num%"=="%info__qcedl__lunnum%" ECHOC {%c_e%}找不到分区%parname%{%c_e%}& call log %logger% F 找不到分区%parname%& goto FATAL
call log %logger% I 回读解析分区表%num%
call partable qcedl readgpt %port% %info__qcedl__memtype% %num% main %tmpdir%\ptanalyse\gpt_main%num%.bin noprompt
ptanalyzer.exe -f %tmpdir%\ptanalyse\gpt_main%num%.bin -m %info__qcedl__memtype% -t gptmain -o normal_clear 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}解析分区表%num%失败{%c_e%}&& call log %logger% F 解析分区表%num%失败&& goto FATAL
type %tmpdir%\output.txt>>%logfile%
set parsizesec=
for /f "tokens=3,5 delims=[] " %%a in ('type %tmpdir%\output.txt ^| find "] %parname% "') do set parstartsec=%%a& set parsizesec=%%b
if "%parsizesec%"=="" set /a num+=1& goto QCEDL-2
::找到目标分区, 开始擦除
call log %logger% I 正在9008擦除%parname%.lun:%num%.起始扇区:%parstartsec%.扇区数目:%parsizesec%
echo.^<erase SECTOR_SIZE_IN_BYTES="%info__qcedl__secsize%" physical_partition_number="%num%" label="%parname%" start_sector="%parstartsec%" num_partition_sectors="%parsizesec%"/^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=%info__qcedl__memtype% --search_path=%tmpdir% --sendxml=%tmpdir%\tmp.xml --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || ECHOC {%c_e%}9008擦除失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 9008擦除失败&& pause>nul && ECHO.重试... && goto QCEDL-1
call log %logger% I 9008擦除完成
ENDLOCAL
goto :eof


:FORMATEXT4
SETLOCAL
set logger=clean.bat-formatext4
set target=%args2%& set label=%args3%
call log %logger% I 接收变量:target:%target%.label:%label%
call framework adbpre mke2fs
call framework adbpre blktool
if "%target:~0,4%"=="name" (goto FORMATEXT4-1) else (goto FORMATEXT4-2)
:FORMATEXT4-1
call info par %target:~5,999%
set parpath=%info__par__path%
goto FORMATEXT4-3
:FORMATEXT4-2
set parpath=%target:~5,999%
goto FORMATEXT4-3
:FORMATEXT4-3
call log %logger% I 尝试卸载%parpath%.若目标分区未挂载则报错属于正常现象
adb.exe shell umount -f -d %parpath% 1>>%logfile% 2>&1
call log %logger% I 开始格式化EXT4.分区路径:%parpath%
set var=
if not "%label%"=="" adb.exe shell ./mke2fs -F -v -t ext4 -L %label% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%label%"=="" adb.exe shell ./mke2fs -F -v -t ext4 %parpath% 1>>%logfile% 2>&1 || set var=n
if "%var%"=="n" ECHOC {%c_e%}格式化EXT4失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 格式化EXT4失败& pause>nul & ECHO.重试... & goto FORMATEXT4-3
call log %logger% I 格式化EXT4完成
ENDLOCAL
goto :eof


:FORMATEXFAT
SETLOCAL
set logger=clean.bat-formatexfat
set target=%args2%& set label=%args3%
call log %logger% I 接收变量:target:%target%.label:%label%
call framework adbpre mkfs.exfat
call framework adbpre blktool
if "%target:~0,4%"=="name" (goto FORMATEXFAT-1) else (goto FORMATEXFAT-2)
:FORMATEXFAT-1
call info par %target:~5,999%
set parpath=%info__par__path%& set disksecsize=%info__par__disksecsize%
goto FORMATEXFAT-3
:FORMATEXFAT-2
set parpath=%target:~5,999%
call log %logger% I 开始获取磁盘扇区大小
set disksecsize=
for /f "tokens=2 delims= " %%a in ('adb.exe shell ./blktool -n -p --print-sector-size ^| find "%parpath%"') do set disksecsize=%%a
if "%disksecsize%"=="" ECHOC {%c_e%}获取磁盘扇区大小失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取磁盘扇区大小失败& pause>nul & ECHO.重试... & goto FORMATEXFAT-2
goto FORMATEXFAT-3
:FORMATEXFAT-3
call log %logger% I 尝试卸载%parpath%.若目标分区未挂载则报错属于正常现象
adb.exe shell umount -f -d %parpath% 1>>%logfile% 2>&1
call log %logger% I 开始格式化EXFAT.分区路径:%parpath%.磁盘扇区大小:%disksecsize%
set var=
if not "%label%"=="" adb.exe shell ./mkfs.exfat -n %label% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%label%"=="" adb.exe shell ./mkfs.exfat %parpath% 1>>%logfile% 2>&1 || set var=n
if "%var%"=="n" ECHOC {%c_e%}格式化EXFAT失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 格式化EXFAT失败& pause>nul & ECHO.重试... & goto FORMATEXFAT-3
call log %logger% I 格式化EXFAT完成
ENDLOCAL
goto :eof


:FORMATFAT32
SETLOCAL
set logger=clean.bat-formatfat32
set target=%args2%& set label=%args3%
call log %logger% I 接收变量:target:%target%.label:%label%
call framework adbpre mkfs.fat
call framework adbpre blktool
if "%target:~0,4%"=="name" (goto FORMATFAT32-1) else (goto FORMATFAT32-2)
:FORMATFAT32-1
call info par %target:~5,999%
set parpath=%info__par__path%& set disksecsize=%info__par__disksecsize%
goto FORMATFAT32-3
:FORMATFAT32-2
set parpath=%target:~5,999%
call log %logger% I 开始获取磁盘扇区大小
set disksecsize=
for /f "tokens=2 delims= " %%a in ('adb.exe shell ./blktool -n -p --print-sector-size ^| find "%parpath%"') do set disksecsize=%%a
if "%disksecsize%"=="" ECHOC {%c_e%}获取磁盘扇区大小失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取磁盘扇区大小失败& pause>nul & ECHO.重试... & goto FORMATFAT32-2
goto FORMATFAT32-3
:FORMATFAT32-3
call log %logger% I 尝试卸载%parpath%.若目标分区未挂载则报错属于正常现象
adb.exe shell umount -f -d %parpath% 1>>%logfile% 2>&1
call log %logger% I 开始格式化FAT32.分区路径:%parpath%.磁盘扇区大小:%disksecsize%
set var=
if not "%label%"=="" adb.exe shell ./mkfs.fat -F 32 -n %label% -S %disksecsize% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%label%"=="" adb.exe shell ./mkfs.fat -F 32 -S %disksecsize% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%var%"=="n" ECHOC {%c_e%}格式化FAT32失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 格式化FAT32失败& pause>nul & ECHO.重试... & goto FORMATFAT32-3
call log %logger% I 格式化FAT32完成
ENDLOCAL
goto :eof


:FORMATNTFS
SETLOCAL
set logger=clean.bat-formatntfs
set target=%args2%& set label=%args3%
call log %logger% I 接收变量:target:%target%.label:%label%
call framework adbpre mkntfs
call framework adbpre blktool
if "%target:~0,4%"=="name" (goto FORMATNTFS-1) else (goto FORMATNTFS-2)
:FORMATNTFS-1
call info par %target:~5,999%
set parpath=%info__par__path%& set disksecsize=%info__par__disksecsize%
goto FORMATNTFS-3
:FORMATNTFS-2
set parpath=%target:~5,999%
call log %logger% I 开始获取磁盘扇区大小
set disksecsize=
for /f "tokens=2 delims= " %%a in ('adb.exe shell ./blktool -n -p --print-sector-size ^| find "%parpath%"') do set disksecsize=%%a
if "%disksecsize%"=="" ECHOC {%c_e%}获取磁盘扇区大小失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取磁盘扇区大小失败& pause>nul & ECHO.重试... & goto FORMATNTFS-2
goto FORMATNTFS-3
:FORMATNTFS-3
call log %logger% I 尝试卸载%parpath%.若目标分区未挂载则报错属于正常现象
adb.exe shell umount -f -d %parpath% 1>>%logfile% 2>&1
call log %logger% I 开始格式化NTFS.分区路径:%parpath%.磁盘扇区大小:%disksecsize%
set var=
if not "%label%"=="" adb.exe shell ./mkntfs -Q -L %label% -s %disksecsize% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%label%"=="" adb.exe shell ./mkntfs -Q -s %disksecsize% %parpath% 1>>%logfile% 2>&1 || set var=n
if "%var%"=="n" ECHOC {%c_e%}格式化NTFS失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 格式化NTFS失败& pause>nul & ECHO.重试... & goto FORMATNTFS-3
call log %logger% I 格式化NTFS完成
ENDLOCAL
goto :eof


:TWRPFACTORYRESET
SETLOCAL
set logger=clean.bat-twrpfactoryreset
call log %logger% I 开始TWRP恢复出厂
:TWRPFACTORYRESET-1
adb.exe shell twrp wipe data 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}TWRP清除Data失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile% && call log %logger% E TWRP清除Data失败&& pause>nul && goto TWRPFACTORYRESET-1
type %tmpdir%\output.txt>>%logfile%
find "ata" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}TWRP清除Data失败, TWRP未执行命令. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E TWRP清除Data失败.TWRP未执行命令&& pause>nul && goto TWRPFACTORYRESET-1
adb.exe shell twrp wipe cache 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}TWRP清除Cache失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile% && call log %logger% E TWRP清除Cache失败&& pause>nul && goto TWRPFACTORYRESET-1
type %tmpdir%\output.txt>>%logfile%
find "ache" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}TWRP清除Cache失败, TWRP未执行命令. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E TWRP清除Cache失败.TWRP未执行命令&& pause>nul && goto TWRPFACTORYRESET-1
adb.exe shell twrp wipe dalvik 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}TWRP清除Dalvik失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile% && call log %logger% E TWRP清除Dalvik失败&& pause>nul && goto TWRPFACTORYRESET-1
type %tmpdir%\output.txt>>%logfile%
find "alvik" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}TWRP清除Dalvik失败, TWRP未执行命令. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E TWRP清除Dalvik失败.TWRP未执行命令&& pause>nul && goto TWRPFACTORYRESET-1
call log %logger% I TWRP恢复出厂完毕
ENDLOCAL
goto :eof


:TWRPFORMATDATA
SETLOCAL
set logger=clean.bat-twrpformatdata
call log %logger% I 开始TWRP格式化Data
:TWRPFORMATDATA-1
adb.exe shell twrp format data 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}TWRP格式化Data失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile% && call log %logger% E TWRP格式化Data失败 && pause>nul && goto TWRPFORMATDATA-1
type %tmpdir%\output.txt>>%logfile%
find "ata" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}TWRP格式化Data失败, TWRP未执行命令. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E TWRP格式化Data失败.TWRP未执行命令&& pause>nul && goto TWRPFORMATDATA-1
call reboot recovery recovery rechk 3
call log %logger% I TWRP格式化Data完毕
ENDLOCAL
goto :eof





:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
