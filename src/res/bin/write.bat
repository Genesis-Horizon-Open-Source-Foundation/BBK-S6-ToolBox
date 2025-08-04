::修改: n

::call write system        分区名               img路径
::           recovery      分区名               img路径
::           fastboot      分区名               img路径
::           fastbootd     分区名               img路径
::           fastbootboot  img路径
::           qcedl         分区名               img路径                      端口号(数字或auto)                                    firehose路径(可选,不填不发送)
::           qcedlxml      端口号(数字或auto)    存储类型(指定或auto)          img所在文件夹                                         xml路径                         firehose路径(可选,不填不发送)
::           qcedlsendfh   端口号(数字或auto)    firehose路径                [auto emmc ufs spinor skip](配置端口方式,可选,默认auto)
::           qcdiag        端口号(数字或auto)    qcn路径
::           twrpinst      zip路径
::           sideload      zip路径
::           adbpush       源文件路径           推送后文件名                  [common program](文件类型,可选,默认common)


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%



:QCEDLSENDFH
SETLOCAL
set logger=write.bat-qcedlsendfh
::接收变量
set port=%args2%& set filepath=%args3%& set configuremode=%args4%
call log %logger% I 接收变量:port:%port%.filepath:%filepath%.configuremode:%configuremode%
::检查firehose是否存在
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
::扩充完整路径
for %%a in ("%filepath%") do set filepath=%%~fa
::如果端口号为auto则自动检查端口
if "%port%"=="auto" call chkdev qcedl 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcedl%
call log %logger% I 正在发送引导
::此处采用通用方案. 有需要可自行增加方案.
goto QCEDLSENDFH-COMMON
:QCEDLSENDFH-COMMON
QSaharaServer.exe -p \\.\COM%port% -s 13:%filepath% 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}发送引导失败. 请将设备重新进入9008. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 发送引导失败&& pause>nul && ECHO.重试... && goto QCEDLSENDFH-COMMON
type %tmpdir%\output.txt>>%logfile%
find "File transferred successfully" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}发送引导失败. 请将设备重新进入9008. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 发送引导失败&& pause>nul && ECHO.重试... && goto QCEDLSENDFH-COMMON
goto QCEDLSENDFH-DONE
:QCEDLSENDFH-DONE
call log %logger% I 发送引导完成
::配置端口
if "%configuremode%"=="skip" ECHOC {%c_w%}已跳过配置端口. 设备读写可能出现异常& call log %logger% W 跳过配置端口& goto QCEDLSENDFH-CONFIGURE-DONE
if "%configuremode%"=="ufs" goto QCEDLSENDFH-CONFIGURE-%configuremode%
if "%configuremode%"=="emmc" goto QCEDLSENDFH-CONFIGURE-%configuremode%
if "%configuremode%"=="spinor" goto QCEDLSENDFH-CONFIGURE-%configuremode%
goto QCEDLSENDFH-CONFIGURE-AUTO
:QCEDLSENDFH-CONFIGURE-UFS
call log %logger% I 尝试%configuremode%模式配置端口
call :qcedlsendfh-configure-tryufs
if "%result%"=="y" call log %logger% I %configuremode%模式配置端口成功
if "%result%"=="n" ECHOC {%c_w%}%configuremode%模式配置端口失败. 设备可能无法正常读写{%c_i%}{\n}& ECHO.继续... & call log %logger% W %configuremode%模式配置端口失败
goto QCEDLSENDFH-CONFIGURE-DONE
:QCEDLSENDFH-CONFIGURE-EMMC
call log %logger% I 尝试%configuremode%模式配置端口
call :qcedlsendfh-configure-tryemmc
if "%result%"=="y" call log %logger% I %configuremode%模式配置端口成功
if "%result%"=="n" ECHOC {%c_w%}%configuremode%模式配置端口失败. 设备可能无法正常读写{%c_i%}{\n}& ECHO.继续... & call log %logger% W %configuremode%模式配置端口失败
goto QCEDLSENDFH-CONFIGURE-DONE
:QCEDLSENDFH-CONFIGURE-SPINOR
call log %logger% I 尝试%configuremode%模式配置端口
call :qcedlsendfh-configure-tryspinor
if "%result%"=="y" call log %logger% I %configuremode%模式配置端口成功
if "%result%"=="n" ECHOC {%c_w%}%configuremode%模式配置端口失败. 设备可能无法正常读写{%c_i%}{\n}& ECHO.继续... & call log %logger% W %configuremode%模式配置端口失败
goto QCEDLSENDFH-CONFIGURE-DONE
:QCEDLSENDFH-CONFIGURE-AUTO
call log %logger% I 尝试ufs模式配置端口
call :qcedlsendfh-configure-tryufs
if "%result%"=="y" call log %logger% I ufs模式配置端口成功& goto QCEDLSENDFH-CONFIGURE-DONE
if "%result%"=="n" call log %logger% I ufs模式配置端口失败
call log %logger% I 尝试emmc模式配置端口
call :qcedlsendfh-configure-tryemmc
if "%result%"=="y" call log %logger% I emmc模式配置端口成功& goto QCEDLSENDFH-CONFIGURE-DONE
if "%result%"=="n" call log %logger% I emmc模式配置端口失败
call log %logger% I 尝试spinor模式配置端口
call :qcedlsendfh-configure-tryspinor
if "%result%"=="y" call log %logger% I spinor模式配置端口成功& goto QCEDLSENDFH-CONFIGURE-DONE
if "%result%"=="n" call log %logger% I spinor模式配置端口失败
ECHOC {%c_w%}自动配置端口失败. 设备可能无法正常读写{%c_i%}{\n}& ECHO.继续... & call log %logger% W 自动配置端口失败
goto QCEDLSENDFH-CONFIGURE-DONE
:qcedlsendfh-configure-tryufs
set result=n
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="4096" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0" num_partition_sectors="6"/^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=ufs --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --noprompt 1>>%logfile% 2>&1 || call log %logger% I 默认参数配置端口失败.尝试去除MaxDigestTableSizeInBytes参数进行配置&& fh_loader.exe --port=\\.\COM%port% --memoryname=ufs --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --fix_config --noprompt 1>>%logfile% 2>&1
find "Got the ACK for the <configure>" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
find "Target returned NAK for your <configure> but it does not seem to be an error" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
goto :eof
:qcedlsendfh-configure-tryemmc
set result=n
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="512" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0" num_partition_sectors="34"/^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=emmc --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --noprompt 1>>%logfile% 2>&1 || call log %logger% I 默认参数配置端口失败.尝试去除MaxDigestTableSizeInBytes参数进行配置&& fh_loader.exe --port=\\.\COM%port% --memoryname=emmc --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --fix_config --noprompt 1>>%logfile% 2>&1
find "Got the ACK for the <configure>" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
find "Target returned NAK for your <configure> but it does not seem to be an error" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
goto :eof
:qcedlsendfh-configure-tryspinor
set result=n
echo.^<?xml version="1.0" ?^>^<data^>^<program SECTOR_SIZE_IN_BYTES="4096" filename="tmp.bin" physical_partition_number="0" label="PrimaryGPT" start_sector="0" num_partition_sectors="6"/^>^</data^>>%tmpdir%\tmp.xml
fh_loader.exe --port=\\.\COM%port% --memoryname=spinor --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% --noprompt 1>>%logfile% 2>&1 || call log %logger% I 默认参数配置端口失败.尝试去除MaxDigestTableSizeInBytes参数进行配置&& fh_loader.exe --port=\\.\COM%port% --memoryname=spinor --sendxml=%tmpdir%\tmp.xml --convertprogram2read --mainoutputdir=%tmpdir% fix_config --noprompt 1>>%logfile% 2>&1
find "Got the ACK for the <configure>" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
find "Target returned NAK for your <configure> but it does not seem to be an error" "%tmpdir%\port_trace.txt" 1>nul 2>nul && set result=y
goto :eof
:QCEDLSENDFH-CONFIGURE-DONE
ENDLOCAL
goto :eof


:QCDIAG
SETLOCAL
set logger=write.bat-qcdiag
::接收变量
set port=%args2%& set filepath=%args3%
call log %logger% I 接收变量:port:%port%.filepath:%filepath%
:QCDIAG-1
::检查qcn是否存在
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
::如果端口号为auto则自动检查端口
if "%port%"=="auto" call chkdev qcdiag 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcdiag%
::开始写入qcn
call log %logger% I 开始写入QCN:%filepath%
QCNTool.exe -w -p %port% -f %filepath% 1>%tmpdir%\output.txt 2>&1
::注意: 原始输出中包含设备IMEI, 如不希望将原始输出保存到日志, 请将下面一行type命令注释掉
type %tmpdir%\output.txt>>%logfile%
find "Writing Data File to phone... OK" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}写入QCN:%filepath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 写入QCN:%filepath%失败&& pause>nul && ECHO.重试... && goto QCDIAG-1
call log %logger% I 写入QCN:%filepath%完成
ENDLOCAL
goto :eof


:ADBPUSH
SETLOCAL
set logger=write.bat-adbpush
::接收变量
set filepath=%args2%& set pushname_full=%args3%& set mode=%args4%
call log %logger% I 接收变量:filepath:%filepath%.pushname_full:%pushname_full%.mode:%mode%
:ADBPUSH-1
::检查是否存在
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
::获取文件名(不包括扩展名)
for %%a in ("%pushname_full%") do set pushname=%%~na
::获取文件扩展名
for %%a in ("%pushname_full%") do set var=%%~xa
if not "%var%"=="" (set pushname_ext=%var:~1,999%) else (set pushname_ext=)
::检查设备模式
call chkdev all 1>nul
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}设备模式错误. {%c_i%}请将设备进入系统或Recovery模式. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备模式错误& pause>nul & ECHO.重试... & goto ADBPUSH-1)
::推送模式
if "%mode:~0,7%"=="program" goto ADBPUSH-PROGRAM-%chkdev__mode%
goto ADBPUSH-COMMON
::推送程序模式-系统
:ADBPUSH-PROGRAM-SYSTEM
set pushfolder=./data/local/tmp
adb.exe push %filepath% ./sdcard/bff.tmp 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}推送%filepath%到./sdcard/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到./sdcard/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
type %tmpdir%\output.txt>>%logfile%
find " 1 file pushed, 0 skipped." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}推送%filepath%到./sdcard/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到./sdcard/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
adb.exe shell mv -f ./sdcard/bff.tmp %pushfolder%/%pushname_full% 1>>%logfile% 2>&1 || ECHOC {%c_e%}移动./sdcard/bff.tmp到%pushfolder%/%pushname_full%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 移动./sdcard/bff.tmp到%pushfolder%/%pushname_full%失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
adb.exe shell chmod 777 %pushfolder%/%pushname_full% 1>>%logfile% 2>&1 || ECHOC {%c_e%}授权%pushfolder%/%pushname_full%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 授权%pushfolder%/%pushname_full%失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
goto ADBPUSH-DONE
::推送程序模式-Recovery
:ADBPUSH-PROGRAM-RECOVERY
set pushfolder=.
adb.exe push %filepath% %pushfolder%/bff.tmp 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}推送%filepath%到%pushfolder%/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到%pushfolder%/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
type %tmpdir%\output.txt>>%logfile%
find " 1 file pushed, 0 skipped." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}推送%filepath%到%pushfolder%/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到%pushfolder%/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
adb.exe shell mv -f %pushfolder%/bff.tmp %pushfolder%/%pushname_full% 1>>%logfile% 2>&1 || ECHOC {%c_e%}移动%pushfolder%/bff.tmp到%pushfolder%/%pushname_full%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 移动%pushfolder%/bff.tmp到%pushfolder%/%pushname_full%失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
adb.exe shell chmod 777 %pushfolder%/%pushname_full% 1>>%logfile% 2>&1 || ECHOC {%c_e%}授权%pushfolder%/%pushname_full%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 授权%pushfolder%/%pushname_full%失败&& pause>nul && ECHO.重试... && goto ADBPUSH-PROGRAM-%chkdev__mode%
goto ADBPUSH-DONE
::通用推送模式
:ADBPUSH-COMMON
set pushfolder=./sdcard
    ::计算文件大小(b)
set filesize=
for /f "tokens=2 delims= " %%a in ('busybox.exe stat -t %filepath%') do set filesize=%%a
if "%filesize%"=="" ECHC {%c_e%}获取%filepath%大小失败{%c_i%}{\n}& call log %logger% F 获取%filepath%大小失败& goto FATAL
    ::获取剩余空间信息(b)
call framework adbpre busybox
set busyboxpath=%write__adbpush__filepath%
adb.exe shell %busyboxpath% df -B 1 2>&1 | find /v "Permission denied" 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
find "Filesystem" "%tmpdir%\output.txt" 1>nul 2>nul || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}获取剩余空间失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 获取剩余空间失败&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
type %tmpdir%\output.txt | busybox.exe tr "\r" "\n" | busybox.exe sed "s/$/\r/g" 1>%tmpdir%\output2.txt 2>&1 || ECHOC {%c_e%}转换%tmpdir%\output.txt换行符失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 转换%tmpdir%\output.txt换行符失败&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
del %tmpdir%\output.txt 1>>%logfile% 2>&1
for /f "tokens=4,6 delims= " %%a in ('type %tmpdir%\output2.txt') do echo.[%%a][%%b]>>%tmpdir%\output.txt
        ::df自动换行的特殊处理
for /f "tokens=3,5 delims= " %%a in ('type %tmpdir%\output2.txt') do echo.[%%a][%%b]>>%tmpdir%\output.txt
    ::比较剩余空间, 获得pushfolder
if "%chkdev__mode%"=="system" (goto ADBPUSH-COMMON-CHKSPACE-SYSTEM) else (goto ADBPUSH-COMMON-CHKSPACE-RECOVERY)
        ::开机状态(sdcard和data任意一个可用均代表sdcard可用)
:ADBPUSH-COMMON-CHKSPACE-SYSTEM
call :adbpush-common-chkspace sdcard
if "%result%"=="y" set pushfolder=./sdcard& goto ADBPUSH-COMMON-PUSH
call :adbpush-common-chkspace data
if "%result%"=="y" set pushfolder=./sdcard& goto ADBPUSH-COMMON-PUSH
ECHOC {%c_e%}设备没有可用的推送路径或空间不足. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备没有可用的推送路径或空间不足& pause>nul & ECHO.重试... & goto ADBPUSH-COMMON
        ::其他状态
:ADBPUSH-COMMON-CHKSPACE-RECOVERY
call :adbpush-common-chkspace tmp
if "%result%"=="y" set pushfolder=./tmp& goto ADBPUSH-COMMON-PUSH
call :adbpush-common-chkspace data
if "%result%"=="y" set pushfolder=./data& goto ADBPUSH-COMMON-PUSH
call :adbpush-common-chkspace sdcard
if "%result%"=="y" set pushfolder=./sdcard& goto ADBPUSH-COMMON-PUSH
ECHOC {%c_e%}设备没有可用的推送路径或空间不足. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备没有可用的推送路径或空间不足& pause>nul & ECHO.重试... & goto ADBPUSH-COMMON
        ::call :adbpush-common-chkspace 关键词(如sdcard)
:adbpush-common-chkspace
set keyword=%1
set var=
for /f "tokens=1 delims=[] " %%a in ('type %tmpdir%\output.txt ^| find "[/%keyword%]"') do set var=%%a
            ::失败
if "%var%"=="" set result=n& goto :eof
            ::如果存在bff.tmp和目标同名文件则排除其大小
set var2=
for /f "tokens=2 delims= " %%a in ('adb.exe shell %busyboxpath% stat -t ./%keyword%/bff.tmp 2^>^&1 ^| find /v "No such file or directory" ^| find "bff.tmp"') do set var2=%%a
if not "%var2%"=="" call calc s var nodec %var% %var2%
set var2=
for /f "tokens=2 delims= " %%a in ('adb.exe shell %busyboxpath% stat -t ./%keyword%/%pushname_full% 2^>^&1 ^| find /v "No such file or directory" ^| find "%pushname_full%"') do set var2=%%a
if not "%var2%"=="" call calc s var nodec %var% %var2%
            ::排除完毕
if not "%var%"=="" call calc numcomp %var% %filesize%
if not "%var%"=="" (if "%calc__numcomp__result%"=="greater" set result=y& goto :eof)
            ::失败
set result=n& goto :eof
:ADBPUSH-COMMON-PUSH
    ::推送文件
adb.exe push %filepath% %pushfolder%/bff.tmp 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}推送%filepath%到%pushfolder%/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到%pushfolder%/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
type %tmpdir%\output.txt>>%logfile%
find " 1 file pushed, 0 skipped." "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}推送%filepath%到%pushfolder%/bff.tmp失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到%pushfolder%/bff.tmp失败&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
adb.exe shell mv -f %pushfolder%/bff.tmp %pushfolder%/%pushname_full% 1>>%logfile% 2>&1 || ECHOC {%c_e%}移动%pushfolder%/bff.tmp到%pushfolder%/%pushname_full%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 移动%pushfolder%/bff.tmp到%pushfolder%/%pushname_full%失败&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
    ::检查大小是否相等
set var=unknown
for /f "tokens=2 delims= " %%a in ('adb.exe shell %busyboxpath% stat -t %pushfolder%/%pushname_full% 2^>^&1 ^| find /v "No such file or directory" ^| find "%pushname_full%"') do set var=%%a
if not "%var%"=="%filesize%" ECHOC {%c_e%}推送%filepath%到%pushfolder%/%pushname_full%失败. 原文件大小%filesize%与推送后文件大小%var%不相等. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%filepath%到%pushfolder%/%pushname_full%失败.原文件大小%filesize%与推送后文件大小%var%不相等&& pause>nul && ECHO.重试... && goto ADBPUSH-COMMON
goto ADBPUSH-DONE
:ADBPUSH-DONE
call log %logger% I adb推送完毕.文件路径:%pushfolder%/%pushname_full%.完整文件名:%pushname_full%.文件名:%pushname%.文件扩展名:%pushname_ext%.所在目录:%pushfolder%
ENDLOCAL & set write__adbpush__filepath=%pushfolder%/%pushname_full%& set write__adbpush__filename_full=%pushname_full%& set write__adbpush__filename=%pushname%& set write__adbpush__folder=%pushfolder%& set write__adbpush__ext=%pushname_ext%
goto :eof


:SIDELOAD
SETLOCAL
set logger=write.bat-sideload
::接收变量
set zippath=%args2%
call log %logger% I 接收变量:zippath:%zippath%
:SIDELOAD-1
::检查是否存在
if not exist %zippath% ECHOC {%c_e%}找不到%zippath%{%c_i%}{\n}& call log %logger% F 找不到%zippath%& goto FATAL
::安装
call reboot recovery sideload rechk 3
call log %logger% I 安装%zippath%
adb.exe sideload %zippath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}安装%zippath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 安装%zippath%失败&& pause>nul && ECHO.重试... && goto SIDELOAD-1
ENDLOCAL
goto :eof


:TWRPINST
SETLOCAL
set logger=write.bat-twrpinst
::接收变量
set zippath=%args2%
call log %logger% I 接收变量:zippath:%zippath%
:TWRPINST-1
::检查是否存在
if not exist %zippath% ECHOC {%c_e%}找不到%zippath%{%c_i%}{\n}& call log %logger% F 找不到%zippath%& goto FATAL
::推送
call log %logger% I 推送%zippath%
call write adbpush %zippath% bff.zip common
::adb.exe push %zippath% ./tmp/bff.zip 1>>%logfile% 2>&1 || ECHOC {%c_e%}推送%zippath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%zippath%失败&& pause>nul && ECHO.重试... && goto TWRPINST-1
::安装
call log %logger% I 安装%write__adbpush__filepath%
adb.exe shell twrp install %write__adbpush__filepath% 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && call log %logger% E 安装%zippath%失败&& ECHOC {%c_e%}安装%zippath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& pause>nul && ECHO.重试... && goto TWRPINST-1
type %tmpdir%\output.txt>>%logfile%
find "zip" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}安装%zippath%失败, TWRP未执行命令. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 安装%zippath%失败,TWRP未执行命令&& pause>nul && ECHO.重试... && goto TWRPINST-1
adb.exe shell rm %write__adbpush__filepath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%write__adbpush__filepath%失败{%c_i%}{\n}&& call log %logger% E 删除%write__adbpush__filepath%失败
ENDLOCAL
goto :eof


:QCEDLXML
SETLOCAL
set logger=write.bat-qcedlxml
::接收变量
set port=%args2%& set memory=%args3%& set searchpath=%args4%& set xml=%args5%& set fh=%args6%
call log %logger% I 接收变量:port:%port%.memory:%memory%.searchpath:%searchpath%.xml:%xml%.fh:%fh%
:QCEDLXML-1
::检查searchpath是否存在
if not exist %searchpath% ECHOC {%c_e%}找不到%searchpath%{%c_i%}{\n}& call log %logger% F 找不到%searchpath%& goto FATAL
::逐个处理xml
call log %logger% I 开始处理xml
    ::清空%tmpdir%\qcedlxml
if exist %tmpdir%\qcedlxml rd /s /q %tmpdir%\qcedlxml 1>>%logfile% 2>&1
md %tmpdir%\qcedlxml 1>>%logfile% 2>&1
    ::开始循环
set xml_new=& set num=1
:QCEDLXML-PROCESSXML
set var=
for /f "tokens=%num% delims=/" %%a in ('echo.%xml%') do set var=%%a
if "%var%"=="" (
    ::if "%xml_new%"=="" ECHOC {%c_e%}缺少xml参数{%c_i%}{\n}& call log %logger% F 缺少xml参数& goto FATAL
    set xml=%xml_new%& goto QCEDLXML-FLASH-START)
if exist %searchpath%\%var% set var=%searchpath%\%var%& goto QCEDLXML-PROCESSXML-1
if exist %var% goto QCEDLXML-PROCESSXML-1
ECHOC {%c_e%}找不到%var%{%c_i%}{\n}& call log %logger% F 找不到%var%& goto FATAL
:QCEDLXML-PROCESSXML-1
    ::复制xml到%tmpdir%\qcedlxml\%num%.xml
copy /Y %var% %tmpdir%\qcedlxml\%num%.xml 1>>%logfile% 2>&1 || ECHOC {%c_e%}复制%var%到%tmpdir%\qcedlxml\%num%.xml失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 复制%var%到%tmpdir%\qcedlxml\%num%.xml失败&& pause>nul && ECHO.重试... && goto QCEDLXML-PROCESSXML-1
    ::尝试格式化xml. 格式化失败则说明非rawprogram, 跳过后续处理, 直接使用原xml
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\%num%.xml -m formatxml -o %tmpdir%\qcedlxml\%num%.xml 1>>%logfile% 2>&1 || goto QCEDLXML-PROCESSXML-NEXT
    ::处理xml-自定义
call :qcedlxml-xmlcustomprocessing %tmpdir%\qcedlxml\%num%.xml
    ::处理xml-转移sparse条目. delline失败说明原xml里均为sparse, 故直接删除xml处理
type %tmpdir%\qcedlxml\%num%.xml | find /v "filename=""""" | find "sparse=""true""" 1>>%tmpdir%\qcedlxml\sparseimg_pre.xml 2>>%logfile% || goto QCEDLXML-PROCESSXML-NEXT
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\%num%.xml -m editxml/delline/sparse/true -o %tmpdir%\qcedlxml\%num%.xml 1>>%logfile% 2>&1 || del %tmpdir%\qcedlxml\%num%.xml 1>>%logfile% 2>&1
:QCEDLXML-PROCESSXML-NEXT
    ::只有存在xml才发送
if exist %tmpdir%\qcedlxml\%num%.xml set xml_new=%xml_new%,%tmpdir%\qcedlxml\%num%.xml
set /a num+=1& goto QCEDLXML-PROCESSXML
    ::结束循环
:QCEDLXML-FLASH-START
::开始刷机
    ::如果端口号为auto则自动检查端口
if "%port%"=="auto" call chkdev qcedl 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcedl%
    ::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% %memory%
    ::如果存储类型为auto则自动识别
if "%memory%"=="auto" (
    call log %logger% I 自动识别存储类型
    call info qcedl %port%)
if "%memory%"=="auto" (
    set memory=%info__qcedl__memtype%
    call log %logger% I 存储类型识别为%info__qcedl__memtype%)
:QCEDLXML-FLASH-RAW
if "%xml%"=="" call log %logger% I xml参数为空.跳过刷入raw部分& goto QCEDLXML-FLASH-SPARSE
::刷入raw部分
call log %logger% I 刷入raw部分
call :qcedlxml-flash-run %searchpath%
if "%result%"=="n" ECHOC {%c_e%}9008刷入失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 9008刷入失败& pause>nul & ECHO.重试... & goto QCEDLXML-FLASH-RAW
:QCEDLXML-FLASH-SPARSE
::刷入sparse部分
call log %logger% I 刷入sparse部分
    ::格式化以确保xml有效. 无效则直接跳过sparse部分
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m formatxml -o %tmpdir%\qcedlxml\sparseimg_pre.xml 1>>%logfile% 2>&1 || call log %logger% I 跳过刷入sparse部分&& goto QCEDLXML-DONE
    ::读取sparse镜像总数
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m readxml/readlinecount 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
set simgcount=
for /f "tokens=2 delims=/ " %%a in ('type %tmpdir%\output.txt ^| find "/result/"') do set simgcount=%%a
if "%simgcount%"=="" ECHOC {%c_e%}读取sparse镜像总数失败{%c_i%}{\n}& call log %logger% F 读取sparse镜像总数失败& goto FATAL
    ::循环逐个刷入sparse镜像
set simgnum=1
:QCEDLXML-FLASH-SPARSE-1
        ::首先尝试fh_loader直接刷入
call log %logger% I 刷入sparse部分-尝试fh_loader直接刷入镜像%simgnum%
            ::准备xml
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m readxml/readline/#/%simgnum% 1>%tmpdir%\qcedlxml\sparseimg.xml 2>&1
type %tmpdir%\qcedlxml\sparseimg.xml>>%logfile%
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg.xml -m formatxml -o %tmpdir%\qcedlxml\sparseimg.xml 1>>%logfile% 2>&1 || ECHOC {%c_w%}格式化sparse分区%simgnum%xml失败. 跳过刷入...{%c_i%}{\n}&& call log %logger% W 格式化sparse分区%simgnum%xml失败.跳过刷入&& goto QCEDLXML-FLASH-SPARSE-NEXT
                ::处理xml-自定义
call :qcedlxml-xmlcustomprocessing %tmpdir%\qcedlxml\sparseimg.xml
set xml=%tmpdir%\qcedlxml\sparseimg.xml
            ::刷入
call :qcedlxml-flash-run %searchpath%
if "%result%"=="y" goto QCEDLXML-FLASH-SPARSE-NEXT
        ::fh_loader直接刷入失败, 解析刷入
ECHOC {%c_w%}fh_loader直接刷入sparse镜像%simgnum%失败. 请向开发者反馈此问题{%c_i%}{\n}& call log %logger% W fh_loader直接刷入sparse镜像%simgnum%失败.请向开发者反馈此问题
call log %logger% I 刷入sparse部分-尝试解析刷入镜像%simgnum%
            ::读取分区参数
                ::start_sector
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m readxml/readvalue/#/%simgnum%/start_sector 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
set parstartsec=
for /f "tokens=2 delims=/ " %%a in ('type %tmpdir%\output.txt ^| find "/result/"') do set parstartsec=%%a
if "%parstartsec%"=="" ECHOC {%c_e%}读取sparse分区%simgnum%start_sector失败. 跳过刷入...{%c_i%}{\n}& call log %logger% E 读取sparse分区%simgnum%start_sector失败.跳过刷入& goto QCEDLXML-FLASH-SPARSE-NEXT
                ::physical_partition_number
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m readxml/readvalue/#/%simgnum%/physical_partition_number 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
set parlun=
for /f "tokens=2 delims=/ " %%a in ('type %tmpdir%\output.txt ^| find "/result/"') do set parlun=%%a
if "%parlun%"=="" ECHOC {%c_e%}读取sparse分区%simgnum%physical_partition_number失败. 跳过刷入...{%c_i%}{\n}& call log %logger% E 读取sparse分区%simgnum%physical_partition_number失败.跳过刷入& goto QCEDLXML-FLASH-SPARSE-NEXT
                ::filename
qcedlxmlhelper.exe -f %tmpdir%\qcedlxml\sparseimg_pre.xml -m readxml/readvalue/#/%simgnum%/filename 1>%tmpdir%\output.txt 2>&1
type %tmpdir%\output.txt>>%logfile%
set parfilename=
for /f "tokens=2 delims=/ " %%a in ('type %tmpdir%\output.txt ^| find "/result/"') do set parfilename=%%a
if "%parfilename%"=="" ECHOC {%c_e%}读取sparse分区%simgnum%filename失败. 跳过刷入...{%c_i%}{\n}& call log %logger% E 读取sparse分区%simgnum%filename失败.跳过刷入& goto QCEDLXML-FLASH-SPARSE-NEXT
            ::检查分区文件是否存在
set parfilepath=
if exist %parfilename% set parfilepath=%parfilename%
if exist %searchpath%\%parfilename% set parfilepath=%searchpath%\%parfilename%
if "%parfilepath%"=="" ECHOC {%c_w%}找不到%parfilename%. 跳过刷入...{%c_i%}{\n}& call log %logger% W 找不到%parfilename%.跳过刷入& goto QCEDLXML-FLASH-SPARSE-NEXT
            ::检查分区文件大小是否为0, 是则跳过. 某些厂商如中兴官方包会放0大小文件, 导致报错
set var=
for /f "tokens=2 delims= " %%a in ('busybox.exe stat -t %parfilepath%') do set var=%%a
if "%var%"=="0" ECHOC {%c_w%}%parfilename%文件大小为0. 跳过刷入...{%c_i%}{\n}& call log %logger% W %parfilename%文件大小为0.跳过刷入& goto QCEDLXML-FLASH-SPARSE-NEXT
            ::解析分区文件(分区名就用sparseimg, 便于自动覆盖之前生成的同名文件, 节约空间)
call log %logger% I 正在解析%parfilepath%
simg_dump.exe -f %parfilepath% -m qcedlrawprogram/%parlun%/sparseimg/%parstartsec% -o %tmpdir%\qcedlxml 1>>%logfile% 2>&1 || ECHOC {%c_w%}解析%parfilepath%失败. 跳过此分区...{%c_i%}{\n}&& call log %logger% W 解析%parfilepath%失败.跳过此分区&& goto QCEDLXML-FLASH-SPARSE-NEXT
            ::处理xml-自定义
call :qcedlxml-xmlcustomprocessing %tmpdir%\qcedlxml\sparseimg.xml
            ::刷入分区文件
set xml=%tmpdir%\qcedlxml\sparseimg.xml
call :qcedlxml-flash-run %tmpdir%\qcedlxml
if "%result%"=="n" ECHOC {%c_w%}刷入%parfilename%失败. 跳过此分区...{%c_i%}{\n}& call log %logger% W 刷入%parfilename%失败.跳过此分区& goto QCEDLXML-FLASH-SPARSE-NEXT
goto QCEDLXML-FLASH-SPARSE-NEXT
:QCEDLXML-FLASH-SPARSE-NEXT
if "%simgnum%"=="%simgcount%" (
    call log %logger% I 刷入sparse部分完成
    goto QCEDLXML-DONE)
set /a simgnum+=1& goto QCEDLXML-FLASH-SPARSE-1
:QCEDLXML-DONE
if exist %tmpdir%\qcedlxml rd /s /q %tmpdir%\qcedlxml 1>>%logfile% 2>&1
call log %logger% I 9008刷入全部完成
ENDLOCAL
goto :eof
::9008刷入
:qcedlxml-flash-run
set result=y
call log %logger% I 正在9008刷入.search_path和sendxml参数如下:
echo.%1 >>%logfile%
echo.%xml% >>%logfile%
fh_loader.exe --port=\\.\COM%port% --memoryname=%memory% --search_path=%1 --sendxml=%xml% --mainoutputdir=%tmpdir% --skip_config --showpercentagecomplete --noprompt 1>>%logfile% 2>&1 || call log %logger% E 9008刷入失败&& set result=n& goto :eof
::--testvipimpact   --zlpawarehost=1
call log %logger% I 9008刷入完成
goto :eof
::自定义处理xml
:qcedlxml-xmlcustomprocessing
::请在此处添加对rawprogram xml的自定义处理. 将要处理的xml路径的变量为%1. 注意: 处理后的xml要覆盖原文件.
goto :eof


:QCEDL
SETLOCAL
set logger=write.bat-qcedl
::接收变量
set parname=%args2%& set filepath=%args3%& set port=%args4%& set fh=%args5%
call log %logger% I 接收变量:parname:%parname%.filepath:%filepath%.port:%port%.fh:%fh%
::检查img是否存在, 获取文件名和所在文件夹路径
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
for %%a in ("%filepath%") do set filepath_fullname=%%~nxa
for %%a in ("%filepath%") do set var=%%~dpa
set filepath_folder=%var:~0,-1%
::检查img是否sparse
set sparse=false
simg_dump.exe -f %filepath% -m basicinfo 1>>%logfile% 2>&1 && set sparse=true
::如果端口号为auto或空则自动检查端口
if not "%port%"=="auto" (if not "%port%"=="" goto QCEDL-2)
call chkdev qcedl 1>nul
set port=%chkdev__port__qcedl%
:QCEDL-2
::发送引导
if not "%fh%"=="" call write qcedlsendfh %port% %fh% auto
::读取设备信息
call info qcedl %port%
::回读, 解析分区表文件
if exist %tmpdir%\ptanalyse rd /s /q %tmpdir%\ptanalyse 1>>%logfile% 2>&1
md %tmpdir%\ptanalyse 1>>%logfile% 2>&1
set num=0
:QCEDL-3
if "%num%"=="%info__qcedl__lunnum%" ECHOC {%c_e%}找不到分区%parname%{%c_e%}& call log %logger% F 找不到分区%parname%& goto FATAL
call log %logger% I 回读解析分区表%num%
call partable qcedl readgpt %port% %info__qcedl__memtype% %num% main %tmpdir%\ptanalyse\gpt_main%num%.bin noprompt
ptanalyzer.exe -f %tmpdir%\ptanalyse\gpt_main%num%.bin -m %info__qcedl__memtype% -t gptmain -o normal_clear 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}解析分区表%num%失败{%c_e%}&& call log %logger% F 解析分区表%num%失败&& goto FATAL
type %tmpdir%\output.txt>>%logfile%
set parsizesec=
for /f "tokens=3,5 delims=[] " %%a in ('type %tmpdir%\output.txt ^| find "] %parname% "') do set parstartsec=%%a& set parsizesec=%%b
if "%parsizesec%"=="" set /a num+=1& goto QCEDL-3
::找到目标分区, 开始刷入
call log %logger% I 正在9008刷入%filepath%.lun:%num%.起始扇区:%parstartsec%.扇区数目:%parsizesec%
::由于部分设备只能使用xml刷入, 故生成xml
echo.^<?xml version="1.0" ?^>^<data^>^<program filename="%filepath_fullname%" physical_partition_number="%num%" label="%parname%" start_sector="%parstartsec%" num_partition_sectors="%parsizesec%" SECTOR_SIZE_IN_BYTES="%info__qcedl__secsize%" sparse="%sparse%"/^>^</data^>>%tmpdir%\tmp.xml
call write qcedlxml %port% %info__qcedl__memtype% %filepath_folder% %tmpdir%\tmp.xml
call log %logger% I 9008刷入完成
ENDLOCAL
goto :eof


:SYSTEM
SETLOCAL
set logger=write.bat-system
set target=system
goto ADBDD


:RECOVERY
SETLOCAL
set logger=write.bat-recovery
set target=recovery
goto ADBDD


:ADBDD
::接收变量
set parname=%args2%& set imgpath=%args3%
call log %logger% I 接收变量:parname:%parname%.imgpath:%imgpath%
:ADBDD-1
::检查文件
if not exist %imgpath% ECHOC {%c_e%}找不到%imgpath%{%c_i%}{\n}& call log %logger% F 找不到%imgpath%& goto FATAL
::系统下要检查Root
if "%target%"=="system" (
    call log %logger% I 开始检查Root
    echo.su>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt
    adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}获取Root失败. 请检查是否已为Shell授权Root权限. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 获取Root失败&& pause>nul && ECHO.重试... && goto ADBDD-1)
::推送
call log %logger% I 开始推送%imgpath%
call write adbpush %imgpath% %parname%.img common
::adb.exe push %imgpath% %target%/%parname%.img 1>>%logfile% 2>&1 || ECHOC {%c_e%}推送%imgpath%到%target%/%parname%.img失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 推送%imgpath%到%target%/%parname%.img失败&& pause>nul && ECHO.重试... && goto ADBDD-1
::获取分区路径
call info par %parname%
::刷入和清理
if "%target%"=="system" echo.su>%tmpdir%\cmd.txt& echo.dd if=%write__adbpush__filepath% of=%info__par__path% >>%tmpdir%\cmd.txt& echo.rm %write__adbpush__filepath%>>%tmpdir%\cmd.txt
if "%target%"=="recovery" echo.dd if=%write__adbpush__filepath% of=%info__par__path% >%tmpdir%\cmd.txt& echo.rm %write__adbpush__filepath%>>%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt & echo.exit>>%tmpdir%\cmd.txt
call log %logger% I 开始刷入%write__adbpush__filepath%到%info__par__path%
adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}刷入%write__adbpush__filepath%到%info__par__path%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 刷入%write__adbpush__filepath%到%info__par__path%失败&& pause>nul && ECHO.重试... && goto ADBDD-1
ENDLOCAL
goto :eof


:FASTBOOT
SETLOCAL
set logger=write.bat-fastboot
::接收变量
set parname=%args2%& set imgpath=%args3%
call log %logger% I 接收变量:parname:%parname%.imgpath:%imgpath%
:FASTBOOT-1
::检查文件
if not exist %imgpath% ECHOC {%c_e%}找不到%imgpath%{%c_i%}{\n}& call log %logger% F 找不到%imgpath%& goto FATAL
::刷入
call log %logger% I 开始刷入%imgpath%到%parname%
fastboot.exe flash %parname% %imgpath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}刷入%imgpath%到%parname%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 刷入%imgpath%到%parname%失败&& pause>nul && ECHO.重试... && goto FASTBOOT-1
ENDLOCAL
goto :eof


:FASTBOOTD
SETLOCAL
set logger=write.bat-fastbootd
::接收变量
set parname=%args2%& set imgpath=%args3%
call log %logger% I 接收变量:parname:%parname%.imgpath:%imgpath%
:FASTBOOTD-1
::检查文件
if not exist %imgpath% ECHOC {%c_e%}找不到%imgpath%{%c_i%}{\n}& call log %logger% F 找不到%imgpath%& goto FATAL
::刷入
call log %logger% I 开始刷入%imgpath%到%parname%
fastboot.exe flash %parname% %imgpath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}刷入%imgpath%到%parname%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 刷入%imgpath%到%parname%失败&& pause>nul && ECHO.重试... && goto FASTBOOTD-1
ENDLOCAL
goto :eof


:FASTBOOTBOOT
SETLOCAL
set logger=write.bat-fastbootboot
::接收变量
set imgpath=%args2%
call log %logger% I 接收变量:imgpath:%imgpath%
:FASTBOOTBOOT-1
::检查文件
if not exist %imgpath% ECHOC {%c_e%}找不到%imgpath%{%c_i%}{\n}& call log %logger% F 找不到%imgpath%& goto FATAL
::临时启动
call log %logger% I 启动%imgpath%
fastboot.exe boot %imgpath% 1>>%logfile% 2>&1 && goto FASTBOOTBOOT-DONE
ECHOC {%c_e%}启动%imgpath%失败{%c_i%}{\n}& call log %logger% E 启动%imgpath%失败
ECHO.1.设备没有进入目标模式, 重新尝试临时启动
ECHO.2.脚本判断有误, 设备已进入目标模式, 可以继续
call input choice [1][2]
if "%choice%"=="2" goto FASTBOOTBOOT-DONE
call chkdev fastboot
ECHO.重新尝试临时启动...
goto FASTBOOTBOOT-1
:FASTBOOTBOOT-DONE
ENDLOCAL
goto :eof








:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)

