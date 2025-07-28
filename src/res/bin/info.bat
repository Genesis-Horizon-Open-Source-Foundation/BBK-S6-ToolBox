::修改: n

::call info adb
::          fastboot
::          qcedl     端口号(数字或auto)  firehose完整路径(可选,不填不发送)
::          par       分区名             [fail back](当找不到分区时的操作.可选.默认为fail)
::          disk      磁盘路径

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%




:QCEDL
SETLOCAL
set logger=info.bat-qcedl
set port=%args2%& set fh=%args3%
call log %logger% I 接收变量:port:%port%.fh:%fh%
:QCEDL-1
::如果端口号为auto或空则自动检查端口
if "%port%"=="auto" call chkdev qcedl 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcedl%
if "%port%"=="" call chkdev qcedl 1>nul
if "%port%"=="" set port=%chkdev__port__qcedl%
::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% auto
::读取设备信息
call log %logger% I 开始9008读取设备信息
set memtype=& set secsize=& set lunnum=
::  判断存储类型和扇区大小 (注意: 先获取ufs, 因为部分ufs设备获取emmc会掉端口)
::    尝试ufs回读
if exist %tmpdir%\tmp.bin del %tmpdir%\tmp.bin 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%tmpdir%\tmp.bin失败{%c_i%}{\n}&& call log %logger% F 删除%tmpdir%\tmp.bin失败&& goto FATAL
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="4096" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0" num_partition_sectors="6" /^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=ufs --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || goto QCEDL-2
if not exist %tmpdir%\tmp.bin goto QCEDL-2
set var=
for /f "tokens=2 delims= " %%a in ('busybox.exe stat -t %tmpdir%\tmp.bin') do set var=%%a
if not "%var%"=="24576" goto QCEDL-2
set memtype=ufs& set secsize=4096& goto QCEDL-TESTLUNNUM
:QCEDL-2
::    尝试emmc回读
if exist %tmpdir%\tmp.bin del %tmpdir%\tmp.bin 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%tmpdir%\tmp.bin失败{%c_i%}{\n}&& call log %logger% F 删除%tmpdir%\tmp.bin失败&& goto FATAL
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="512" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0" num_partition_sectors="34"/^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=emmc --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || goto QCEDL-3
if not exist %tmpdir%\tmp.bin goto QCEDL-3
set var=
for /f "tokens=2 delims= " %%a in ('busybox.exe stat -t %tmpdir%\tmp.bin') do set var=%%a
if not "%var%"=="17408" goto QCEDL-3
set memtype=emmc& set secsize=512& set lunnum=1& goto QCEDL-DONE
:QCEDL-3
::    尝试spinor回读
if exist %tmpdir%\tmp.bin del %tmpdir%\tmp.bin 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%tmpdir%\tmp.bin失败{%c_i%}{\n}&& call log %logger% F 删除%tmpdir%\tmp.bin失败&& goto FATAL
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="4096" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0"  num_partition_sectors="6" /^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=spinor --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || goto QCEDL-FAILED
if not exist %tmpdir%\tmp.bin goto QCEDL-FAILED
set var=
for /f "tokens=2 delims= " %%a in ('busybox.exe stat -t %tmpdir%\tmp.bin') do set var=%%a
if not "%var%"=="24576" goto QCEDL-FAILED
set memtype=spinor& set secsize=4096& set lunnum=1& goto QCEDL-DONE
::  测试ufs可用lun总数
:QCEDL-TESTLUNNUM
call log %logger% I 测试ufs可用lun总数
set num=0
:QCEDL-TESTLUNNUM-1
if %num% GTR 8 ECHOC {%c_w%}当前设备可用lun总数为%num%. 常规lun总数应小于等于8. 请向开发者反馈.{%c_i%}{\n}& call log %logger% W 当前设备可用lun总数为%num%.常规lun总数应小于等于8
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="4096" filename="gpt_main%num%.bin" physical_partition_number="%num%" label="PrimaryGPT" start_sector="0" num_partition_sectors="6" /^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=ufs --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --skip_config --noprompt 1>>%logfile% 2>&1 || goto QCEDL-TESTLUNNUM-2
ptanalyzer.exe -f %tmpdir%\gpt_main%num%.bin -m ufs -t gptmain -o normal_clear 1>>%logfile% 2>&1 || goto QCEDL-TESTLUNNUM-2
set /a num+=1& goto QCEDL-TESTLUNNUM-1
:QCEDL-TESTLUNNUM-2
if %num% EQU 0 ECHOC {%c_e%}当前设备可用lun总数为%num%.{%c_i%}{\n}& call log %logger% E 当前设备可用lun总数为%num%& goto QCEDL-FAILED
if %num% LSS 6 ECHOC {%c_w%}当前设备可用lun总数为%num%. 常规lun总数应大于等于6. 请向开发者反馈.{%c_i%}{\n}& call log %logger% W 当前设备可用lun总数为%num%.常规lun总数应大于等于6
set lunnum=%num%& goto QCEDL-DONE
:QCEDL-DONE
call log %logger% I 9008读取到设备信息:存储类型:%memtype%.扇区大小:%secsize%.lun总数:%lunnum%
ENDLOCAL & set info__qcedl__memtype=%memtype%& set info__qcedl__secsize=%secsize%& set info__qcedl__lunnum=%lunnum%
goto :eof
:QCEDL-FAILED
ECHOC {%c_e%}9008读取设备信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 9008读取设备信息失败.当前结果:存储类型:%memtype%.扇区大小:%secsize%.lun总数:%lunnum%& pause>nul & ECHO.重试... & goto QCEDL-1


:ADB
SETLOCAL
set logger=info.bat-adb
call log %logger% I 开始读取ADB设备信息
:ADB-1
set product=
for /f %%a in ('adb.exe shell getprop ro.product.device') do set product=%%a
if "%product%"=="" call log %logger% E ro.product.device读取失败& ECHOC {%c_e%}ro.product.device读取失败. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto ADB-1
set androidver=
for /f %%a in ('adb.exe shell getprop ro.build.version.release') do set androidver=%%a
if "%androidver%"=="" call log %logger% E ro.build.version.release读取失败& ECHOC {%c_e%}ro.build.version.release读取失败. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto ADB-1
set sdkver=
for /f %%a in ('adb.exe shell getprop ro.build.version.sdk') do set sdkver=%%a
if "%sdkver%"=="" call log %logger% E ro.build.version.sdk读取失败& ECHOC {%c_e%}ro.build.version.sdk读取失败. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto ADB-1
call log %logger% I 读取到ADB设备信息:product:%product%.androidver:%androidver%.sdkver:%sdkver%
ENDLOCAL & set info__adb__product=%product%& set info__adb__androidver=%androidver%& set info__adb__sdkver=%sdkver%
goto :eof


:FASTBOOT
SETLOCAL
set logger=info.bat-fastboot
call log %logger% I 开始读取Fastboot设备信息
:FASTBOOT-1
set product=
for /f "tokens=2 delims=: " %%a in ('fastboot getvar product 2^>^&1^| find "product"') do set product=%%a
if "%product%"=="" call log %logger% E product读取失败& ECHOC {%c_e%}product读取失败. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto FASTBOOT-1
set unlocked=
for /f "tokens=2 delims=: " %%a in ('fastboot getvar unlocked 2^>^&1^| find "unlocked"') do set unlocked=%%a
if "%unlocked%"=="" call log %logger% E unlocked读取失败& ECHOC {%c_e%}unlocked读取失败. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto FASTBOOT-1
call log %logger% I 读取到Fastboot设备信息:product:%product%.unlocked:%unlocked%
ENDLOCAL & set info__fastboot__product=%product%& set info__fastboot__unlocked=%unlocked%
goto :eof
::附:摩托罗拉设备判断解锁的方法如下: fastboot getvar securestate 2>&1| find "flashing_unlocked" 1>nul 2>nul && set unlocked=yes


:PAR
SETLOCAL
set logger=info.bat-par
set parname=%args2%& set ifparnotexist=%args3%
if "%ifparnotexist%"=="" set ifparnotexist=fail
call log %logger% I 接收变量:parname:%parname%.ifparnotexist:%ifparnotexist%
:PAR-1
call chkdev all 1>nul
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}设备模式错误, 只支持在系统或Recovery获取分区路径. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 模式错误:%chkdev__mode%.应进入系统或Recovery模式& pause>nul & ECHO.重试... & goto PAR-1)
call log %logger% I 开始读取分区信息
::blktool读取分区基础信息
call framework adbpre blktool
if "%chkdev__mode%"=="system" echo.su>%tmpdir%\cmd.txt& echo../data/local/tmp/blktool -n -N %parname% --print-part -l --print-sector-size>>%tmpdir%\cmd.txt
if "%chkdev__mode%"=="recovery" echo../blktool -n -N %parname% --print-part -l --print-sector-size>%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
adb.exe shell < %tmpdir%\cmd.txt 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
    ::判断分区是否存在 parexist
set parexist=y
find "list failed: no any match block found" "%tmpdir%\output.txt" 1>nul 2>nul && set parexist=n
if "%parexist%"=="n" (
    if "%ifparnotexist%"=="fail" ECHOC {%c_e%}%parname%分区不存在. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E %parname%分区不存在& pause>nul & ECHO.重试... & goto PAR-1
    if "%ifparnotexist%"=="back" (
        call log %logger% I %parname%分区不存在.退出读取分区信息
        ENDLOCAL & set info__par__exist=n
        goto :eof))
    ::分区存在, 获取 parnum parpath disksecsize
set parnum=& set parpath=& set disksecsize=
for /f "tokens=1,2,3 delims= " %%a in ('type %tmpdir%\output.txt ^| find /v "blktool" ^| find "/"') do (set parnum=%%a& set parpath=%%b& set disksecsize=%%c)
if "%parnum%"=="" ECHOC {%c_e%}获取分区编号失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取分区编号失败& pause>nul & ECHO.重试... & goto PAR-1
if "%parpath%"=="" ECHOC {%c_e%}获取分区路径失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取分区路径失败& pause>nul & ECHO.重试... & goto PAR-1
if "%disksecsize%"=="" ECHOC {%c_e%}获取磁盘扇区大小失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取磁盘扇区大小失败& pause>nul & ECHO.重试... & goto PAR-1
    ::获取 disktype
set disktype=
if "%disksecsize%"=="512"  set disktype=emmc
if "%disksecsize%"=="4096" set disktype=ufs
if "%disktype%"=="" ECHOC {%c_e%}不支持的格式:扇区大小为%disksecsize%{%c_i%}{\n}& call log %logger% F 不支持的格式:扇区大小为%disksecsize%& goto FATAL
    ::获取 diskpath
set var=
for /f "tokens=1,2,3 delims= " %%a in ('echo.%parpath%# ^| busybox.exe sed "s/%parnum%#//g"') do set var=%%a
if "%disktype%"=="emmc" set diskpath=%var:~0,-1%
if "%disktype%"=="emmc" (if not "%diskpath%"=="/dev/block/mmcblk0" ECHOC {%c_e%}不支持的格式:磁盘路径为%diskpath%{%c_i%}{\n}& call log %logger% F 不支持的格式:磁盘路径为%diskpath%& goto FATAL)
if "%disktype%"=="ufs" set diskpath=%var%
if "%disktype%"=="ufs" (if not "%diskpath:~0,13%"=="/dev/block/sd" ECHOC {%c_e%}不支持的格式:磁盘路径为%diskpath%{%c_i%}{\n}& call log %logger% F 不支持的格式:磁盘路径为%diskpath%& goto FATAL)
::读取分区表获取分区起止大小类型
:PAR-GETGPT
call partable %chkdev__mode% sgdiskbakpartable %diskpath% %tmpdir%\tmp.bin noprompt
::if "%disktype%"=="emmc" (set var=34) else (set var=6)
::if "%chkdev__mode%"=="system" (
::    echo.su>%tmpdir%\cmd.txt & echo.dd if=%diskpath% of=./data/local/tmp/bff.tmp bs=%disksecsize% count=%var% >>%tmpdir%\cmd.txt && echo.mv ./data/local/tmp/bff.tmp ./sdcard/bff.tmp>>%tmpdir%\cmd.txt && echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
::    adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}读取分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 读取分区表失败&& pause>nul && ECHO.重试... && goto PAR-GETGPT
::    call read adbpull ./sdcard/bff.tmp %tmpdir%\tmp.bin noprompt)
::if "%chkdev__mode%"=="recovery" (
::    adb.exe shell dd if=%diskpath% of=./bff.tmp bs=%disksecsize% count=%var% 1>>%logfile% 2>&1 || ECHOC {%c_e%}读取分区表失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 读取分区表失败&& pause>nul && ECHO.重试... && goto PAR-GETGPT
::    call read adbpull ./bff.tmp %tmpdir%\tmp.bin noprompt)
:PAR-READGPT
ptanalyzer.exe -f %tmpdir%\tmp.bin -m %disktype% -t sgdiskgptbak -o normal_entire 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "Analysis completed." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}解析分区表失败{%c_i%}{\n}&& call log %logger% F 解析分区表失败&& goto FATAL
set parstart_sec=unknown& set parend_sec=unknown& set parsize_sec=unknown& set partype=unknown
for /f "tokens=3,4,5,6 delims= " %%a in ('type %tmpdir%\output.txt ^| find "[%parnum%]" ^| find " %parname% "') do (set parstart_sec=%%a& set parend_sec=%%b& set parsize_sec=%%c& set partype=%%d)
call calc sec2b parstart nodec %parstart_sec% %disksecsize%
call calc sec2b parend nodec %parend_sec% %disksecsize%
call calc sec2b parsize nodec %parsize_sec% %disksecsize%
call log %logger% I 读取分区信息完成:parexist:%parexist%.diskpath:%diskpath%.parnum:%parnum%.parpath:%parpath%.partype:%partype%.parstart:%parstart%.parend:%parend%.parsize:%parsize%.disksecsize:%disksecsize%.disktype:%disktype%
ENDLOCAL & set info__par__exist=%parexist%& set info__par__diskpath=%diskpath%& set info__par__num=%parnum%& set info__par__path=%parpath%& set info__par__type=%partype%& set info__par__start=%parstart%& set info__par__end=%parend%& set info__par__size=%parsize%& set info__par__disksecsize=%disksecsize%& set info__par__disktype=%disktype%
goto :eof


:DISK
SETLOCAL
set logger=info.bat-disk
set diskpath=%args2%
call log %logger% I 接收变量:diskpath:%diskpath%
call framework adbpre blktool
call framework adbpre sgdisk
:DISK-3
call chkdev all 1>nul
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}设备模式错误, 只支持在系统或Recovery获取分区路径. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 模式错误:%chkdev__mode%.应进入系统或Recovery模式& pause>nul & ECHO.重试... & goto DISK-3)
::获取存储类型
echo.%diskpath% | find "mmcblk" 1>nul 2>nul && set disktype=emmc&& call log %logger% I 获取存储类型完成:emmc&& goto DISK-1
echo.%diskpath% | find "dev/block/sd" 1>nul 2>nul && set disktype=ufs&& call log %logger% I 获取存储类型完成:ufs&& goto DISK-1
ECHOC {%c_e%}不支持的存储类型{%c_i%}{\n}& call log %logger% F 不支持的存储类型& goto FATAL
::获取磁盘扇区大小
:DISK-1
if "%chkdev__mode%"=="system" echo.su>%tmpdir%\cmd.txt& echo../data/local/tmp/blktool -n -p --print-sector-size>>%tmpdir%\cmd.txt
if "%chkdev__mode%"=="recovery" echo../blktool -n -p --print-sector-size>%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
set disksecsize=
for /f "tokens=2 delims= " %%a in ('adb.exe shell ^< %tmpdir%\cmd.txt ^| find "%diskpath%" ^| busybox.exe sed "s/\r/\r\n/g"') do set disksecsize=%%a
if "%disksecsize%"=="" (ECHOC {%c_e%}获取磁盘扇区大小失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取磁盘扇区大小失败& pause>nul & ECHO.重试... & goto DISK-1) else (call log %logger% I 获取磁盘扇区大小完成:%disksecsize%)
::获取最大分区数
:DISK-2
if "%chkdev__mode%"=="system" echo.su>%tmpdir%\cmd.txt& echo../data/local/tmp/sgdisk -p %diskpath% >>%tmpdir%\cmd.txt
if "%chkdev__mode%"=="recovery" echo../sgdisk -p %diskpath% >%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
set maxparnum=
for /f "tokens=6 delims= " %%a in ('adb.exe shell ^< %tmpdir%\cmd.txt ^| find "Partition table holds up to " ^| busybox.exe sed "s/\r/\r\n/g"') do set maxparnum=%%a
if "%maxparnum%"=="" (ECHOC {%c_e%}获取最大分区数失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取最大分区数失败& pause>nul & ECHO.重试... & goto DISK-2) else (call log %logger% I 获取最大分区数完成:%maxparnum%)
call log %logger% I 读取磁盘信息完成
ENDLOCAL & set info__disk__type=%disktype%& set info__disk__secsize=%disksecsize%& set info__disk__maxparnum=%maxparnum%
goto :eof















:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
