::修改: n

::call partable recovery mkpar             磁盘路径            分区名                  类型            start         [end:xxx(默认)或size:xxx]  编号(可选,默认为首个可用的)
::              recovery rmpar             磁盘路径            [name:xxx或numb:xx]
::              recovery setmaxparnum      磁盘路径            目标分区数(可选,默认128)
::              recovery sgdiskbakpartable 磁盘路径            保存路径(包括文件名)     noprompt(可选)
::              system   sgdiskbakpartable 磁盘路径            保存路径(包括文件名)     noprompt(可选)
::              recovery sgdiskrecpartable 磁盘路径            文件路径
::              qcedl    readgpt           端口号(数字或auto)  [ufs emmc spinor auto] 目标lun编号     [main backup]  文件保存路径               [notice noprompt]              firehose路径(可选,不填不发送)
::              qcedl    writegpt          端口号(数字或auto)  [ufs emmc spinor auto] 目标lun编号     [main backup]  文件路径                   firehose路径(可选,不填不发送)


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%-%args2%







:QCEDL-WRITEGPT
SETLOCAL
set logger=partable.bat-qcedl-writegpt
set port=%args3%& set memtype=%args4%& set lun=%args5%& set gpttype=%args6%& set filepath=%args7%& set fh=%args8%
call log %logger% I 接收变量:port:%port%.memtype:%memtype%.lun:%lun%.gpttype:%gpttype%.filepath:%filepath%.fh:%fh%
:QCEDL-WRITEGPT-1
::检查文件是否存在
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
::获取文件名和所在目录
for %%a in ("%filepath%") do set filepath_fullname=%%~nxa
for %%a in ("%filepath%") do set var=%%~dpa
set filepath_folder=%var:~0,-1%
::如果端口号为auto则自动检查端口
if "%port%"=="auto" call chkdev qcedl 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcedl%
::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% auto
::确定存储类型和扇区大小
set secsize=
if "%memtype%"=="emmc" set secsize=512
if "%memtype%"=="ufs" set secsize=4096
if "%memtype%"=="spinor" set secsize=4096
if "%memtype%"=="auto" call info qcedl %port%
if "%memtype%"=="auto" set memtype=%info__qcedl__memtype%& set secsize=%info__qcedl__secsize%
if "%secsize%"=="" ECHOC {%c_e%}参数错误{%c_i%}{\n}& call log %logger% F 参数错误& goto FATAL
::生成xml
if not "%gpttype%"=="backup" (
    if "%secsize%"=="4096"     echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="PrimaryGPT" start_sector="0"                    num_partition_sectors="6" /^>^</data^>>%tmpdir%\tmp.xml
    if not "%secsize%"=="4096" echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="PrimaryGPT" start_sector="0"                    num_partition_sectors="34"/^>^</data^>>%tmpdir%\tmp.xml)
if "%gpttype%"=="backup" (
    if "%secsize%"=="4096"     echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="BackupGPT"  start_sector="NUM_DISK_SECTORS-5."  num_partition_sectors="5" /^>^</data^>>%tmpdir%\tmp.xml
    if not "%secsize%"=="4096" echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="BackupGPT"  start_sector="NUM_DISK_SECTORS-33." num_partition_sectors="33"/^>^</data^>>%tmpdir%\tmp.xml)
::开始刷机
call log %logger% I 正在9008刷入分区表%gpttype%%lun%
fh_loader.exe --port=\\.\COM%port% --memoryname=%memtype% --sendxml=%tmpdir%\tmp.xml --search_path=%filepath_folder% --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || ECHOC {%c_e%}9008刷入分区表%gpttype%%lun%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 9008刷入分区表%gpttype%%lun%失败&& pause>nul && ECHO.重试... && goto QCEDL-WRITEGPT-1
call log %logger% I 9008刷入分区表%gpttype%%lun%完成
ENDLOCAL
goto :eof


:QCEDL-READGPT
SETLOCAL
set logger=partable.bat-qcedl-readgpt
set port=%args3%& set memtype=%args4%& set lun=%args5%& set gpttype=%args6%& set filepath=%args7%& set mode=%args8%& set fh=%args9%
call log %logger% I 接收变量:port:%port%.memtype:%memtype%.lun:%lun%.gpttype:%gpttype%.filepath:%filepath%.mode:%mode%.fh:%fh%
:QCEDL-READGPT-1
::获取文件名
for %%a in ("%filepath%") do set filepath_fullname=%%~nxa
::检查文件所在目录是否存在
for %%a in ("%filepath%") do set var=%%~dpa
set filepath_folder=%var:~0,-1%
if not exist %filepath_folder% ECHOC {%c_e%}找不到%filepath_folder%{%c_i%}{\n}& call log %logger% F 找不到%filepath_folder%& goto FATAL
::检查文件是否存在
if exist %filepath% (if not "%mode%"=="noprompt" ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% auto
::确定存储类型和扇区大小
set secsize=
if "%memtype%"=="emmc" set secsize=512
if "%memtype%"=="ufs" set secsize=4096
if "%memtype%"=="spinor" set secsize=4096
if "%memtype%"=="auto" call info qcedl %port%
if "%memtype%"=="auto" set memtype=%info__qcedl__memtype%& set secsize=%info__qcedl__secsize%
if "%secsize%"=="" ECHOC {%c_e%}参数错误{%c_i%}{\n}& call log %logger% F 参数错误& goto FATAL
::生成xml
if not "%gpttype%"=="backup" (
    if "%secsize%"=="4096"     echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="PrimaryGPT" start_sector="0"                    num_partition_sectors="6" /^>^</data^>>%tmpdir%\tmp.xml
    if not "%secsize%"=="4096" echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="PrimaryGPT" start_sector="0"                    num_partition_sectors="34"/^>^</data^>>%tmpdir%\tmp.xml)
if "%gpttype%"=="backup" (
    if "%secsize%"=="4096"     echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="BackupGPT"  start_sector="NUM_DISK_SECTORS-5."  num_partition_sectors="5" /^>^</data^>>%tmpdir%\tmp.xml
    if not "%secsize%"=="4096" echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="%secsize%" filename="%filepath_fullname%" physical_partition_number="%lun%" label="BackupGPT"  start_sector="NUM_DISK_SECTORS-33." num_partition_sectors="33"/^>^</data^>>%tmpdir%\tmp.xml)
::开始刷机
call log %logger% I 正在9008回读分区表%gpttype%%lun%
fh_loader.exe --port=\\.\COM%port% --memoryname=%memtype% --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%filepath_folder% --skip_config --noprompt 1>>%logfile% 2>&1 || ECHOC {%c_e%}9008回读分区表%gpttype%%lun%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 9008回读分区表%gpttype%%lun%失败&& pause>nul && ECHO.重试... && goto QCEDL-READGPT-1
move /Y %filepath_folder%\port_trace.txt %tmpdir% 1>>%logfile% 2>&1
call log %logger% I 9008回读分区表%gpttype%%lun%完成
ENDLOCAL
goto :eof


:RECOVERY-SGDISKRECPARTABLE
SETLOCAL
set logger=partable.bat-recovery-sgdiskrecpartable
set diskpath=%args3%& set filepath=%args4%
call log %logger% I 接收变量:diskpath:%diskpath%.filepath:%filepath%
:RECOVERY-SGDISKRECPARTABLE-1
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
call framework adbpre sgdisk
call write adbpush %filepath% bff_sgdiskpartable.bak common
::adb.exe push %filepath% ./bff_sgdiskpartable.bak 1>>%logfile% 2>&1 || ECHOC {%c_e%}推送分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送分区表失败&& pause>nul && ECHO.重试... && goto RECOVERY-SGDISKRECPARTABLE-1
adb.exe shell ./sgdisk -l %write__adbpush__filepath% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}恢复分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 恢复分区表失败&& pause>nul && ECHO.重试... && goto RECOVERY-SGDISKRECPARTABLE-1
call log %logger% I 恢复分区表完成
ENDLOCAL
goto :eof


:RECOVERY-SGDISKBAKPARTABLE
SETLOCAL
set logger=partable.bat-recovery-sgdiskbakpartable
set diskpath=%args3%& set filepath=%args4%& set mode=%args5%
call log %logger% I 接收变量:diskpath:%diskpath%.filepath:%filepath%.mode:%mode%
if not "%mode%"=="noprompt" (if exist %filepath% ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
:RECOVERY-SGDISKBAKPARTABLE-1
call framework adbpre sgdisk
adb.exe shell ./sgdisk -b ./bff_sgdiskpartable.bak %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}备份分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 备份分区表失败&& pause>nul && ECHO.重试... && goto RECOVERY-SGDISKBAKPARTABLE-1
call read adbpull ./bff_sgdiskpartable.bak %filepath% noprompt
call log %logger% I 备份分区表完成
ENDLOCAL
goto :eof


:SYSTEM-SGDISKBAKPARTABLE
SETLOCAL
set logger=partable.bat-system-sgdiskbakpartable
set diskpath=%args3%& set filepath=%args4%& set mode=%args5%
call log %logger% I 接收变量:diskpath:%diskpath%.filepath:%filepath%.mode:%mode%
if not "%mode%"=="noprompt" (if exist %filepath% ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
:SYSTEM-SGDISKBAKPARTABLE-1
call framework adbpre sgdisk
echo.su>%tmpdir%\cmd.txt
echo../data/local/tmp/sgdisk -b ./data/local/tmp/bff_sgdiskpartable.bak %diskpath% >>%tmpdir%\cmd.txt
echo.mv ./data/local/tmp/bff_sgdiskpartable.bak ./sdcard/bff_sgdiskpartable.bak>>%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
adb.exe shell < %tmpdir%\cmd.txt 1>>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}备份分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 备份分区表失败&& pause>nul && ECHO.重试... && goto SYSTEM-SGDISKBAKPARTABLE-1
call read adbpull ./sdcard/bff_sgdiskpartable.bak %filepath% noprompt
call log %logger% I 备份分区表完成
ENDLOCAL
goto :eof


:RECOVERY-MKPAR
SETLOCAL
set logger=partable.bat-recovery-mkpar
set diskpath=%args3%& set parname=%args4%& set partype=%args5%& set parstart=%args6%& set parenddata=%args7%& set parnum=%args8%
call log %logger% I 接收变量:parname:%parname%.partype:%partype%.parstart:%parstart%.parenddata:%parenddata%.parnum:%parnum%
call framework adbpre sgdisk
if not "%parnum%"=="" goto RECOVERY-MKPAR-3
:RECOVERY-MKPAR-1
call log %logger% I 开始获取可用的分区编号
adb.exe shell ./sgdisk -p %diskpath% 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}获取可用的分区编号失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile% && call log %logger% E 获取可用的分区编号失败&& pause>nul && ECHO.重试... && goto RECOVERY-MKPAR-1
type %tmpdir%\output.txt>>%logfile%
if exist %tmpdir%\output2.txt del %tmpdir%\output2.txt 1>nul
for /f "tokens=1 delims= " %%a in ('type %tmpdir%\output.txt ^| find "  " ^| find /v "Number"') do echo.[%%a]>>%tmpdir%\output2.txt
set num=1
:RECOVERY-MKPAR-2
find "[%num%]" "%tmpdir%\output2.txt" 1>nul 2>nul || set parnum=%num%&& goto RECOVERY-MKPAR-3
set /a num+=1& goto RECOVERY-MKPAR-2
:RECOVERY-MKPAR-3
call log %logger% I 开始读取磁盘扇区大小& call info disk %diskpath%
call log %logger% I 开始计算分区参数
::解析parenddata获取parend
set parend=
if "%parenddata:~0,4%"=="end:" set parend=%parenddata:~4,999%
if "%parenddata:~0,5%"=="size:" call calc p var    nodec %parstart% %parenddata:~5,999%
if "%parenddata:~0,5%"=="size:" call calc s parend nodec %var%      %info__disk__secsize%
::if "%parend%"=="" ECHOC {%c_e%}参数错误{%c_i%}{\n}& call log %logger% F 参数错误& goto FATAL
if "%parend%"=="" set parend=%parenddata%
call calc b2sec parstart_sec nodec %parstart% %info__disk__secsize%
call calc b2sec parend_sec nodec %parend% %info__disk__secsize%
:RECOVERY-MKPAR-4
call log %logger% I 开始创建分区.编号:%parnum%.start扇区:%parstart_sec%.end扇区:%parend_sec%
adb.exe shell ./sgdisk -n %parnum%:%parstart_sec%:%parend_sec% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}创建分区失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 创建分区失败&& pause>nul && ECHO.重试... && goto RECOVERY-MKPAR-4
:RECOVERY-MKPAR-5
call log %logger% I 开始命名分区
adb.exe shell ./sgdisk -c %parnum%:%parname% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}命名分区失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 命名分区失败&& pause>nul && ECHO.重试... && goto RECOVERY-MKPAR-5
:RECOVERY-MKPAR-6
call log %logger% I 开始设置分区类型
adb.exe shell ./sgdisk -t %parnum%:%partype% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}设置分区类型失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 设置分区类型失败&& pause>nul && ECHO.重试... && goto RECOVERY-MKPAR-6
::call reboot recovery recovery rechk 3
call log %logger% I 创建分区完成
ENDLOCAL
goto :eof


:RECOVERY-RMPAR
SETLOCAL
set logger=partable.bat-recovery-rmpar
set diskpath=%args3%& set target=%args4%
call log %logger% I 接收变量:diskpath:%diskpath%.target:%target%
call framework adbpre sgdisk
if "%target:~0,4%"=="numb" set parnum=%target:~5,999%& goto RECOVERY-RMPAR-2
:RECOVERY-RMPAR-1
call log %logger% I 开始获取分区编号.分区名为%target:~5,999%
call info par %target:~5,999%
set parnum=%info__par__num%
goto RECOVERY-RMPAR-2
:RECOVERY-RMPAR-2
call log %logger% I 开始删除分区.目标编号为%parnum%
adb.exe shell ./sgdisk -d %parnum% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}删除分区失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 删除分区失败&& pause>nul && ECHO.重试... && goto RECOVERY-RMPAR-2
::call reboot recovery recovery rechk 3
call log %logger% I 删除分区完成
ENDLOCAL
goto :eof


:RECOVERY-SETMAXPARNUM
SETLOCAL
set logger=partable.bat-recovery-setmaxparnum
set diskpath=%args3%& set target=%args4%
if "%target%"=="" set target=128
call log %logger% I 接收变量:diskpath:%diskpath%.target:%target%
call framework adbpre sgdisk
:RECOVERY-SETMAXPARNUM-1
call log %logger% I 开始设置最大分区数
adb.exe shell ./sgdisk --resize-table=%target% %diskpath% 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "The operation has completed successfully." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}设置最大分区数失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 设置最大分区数失败&& pause>nul && ECHO.重试... && goto RECOVERY-SETMAXPARNUM-1
call log %logger% I 设置最大分区数完成
ENDLOCAL
goto :eof















:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)


