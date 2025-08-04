::修改: n

::call read system        分区名             文件保存路径(包括文件名)                 noprompt(可选)
::          recovery      分区名             文件保存路径(包括文件名)                 noprompt(可选)
::          qcedl         分区名             文件保存路径(包括文件名)                 noprompt或notice   端口号(数字或auto)  firehose完整路径(可选,不填不发送)
::          qcedlxml      端口号(数字或auto)  存储类型(指定或auto)                    img存放文件夹       xml路径            firehose完整路径(可选,不填不发送)
::          qcdiag        端口号(数字或auto)  文件保存路径(包括文件名)                 noprompt(可选)
::          adbpull       源文件路径          文件保存路径(包括文件名)                 noprompt(可选)

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%





:ADBPULL
SETLOCAL
set logger=read.bat-adbpull
::接收变量
set filepath=%args2%& set outputpath=%args3%& set mode=%args4%
call log %logger% I 接收变量:filepath:%filepath%.outputpath:%outputpath%.mode:%mode%
:ADBPULL-1
::检查保存路径是否存在
if exist %outputpath% (if not "%mode%"=="noprompt" ECHOC {%c_w%}已存在%outputpath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%outputpath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
::获取保存文件名
for %%a in ("%outputpath%") do set outputpath_fullname=%%~nxa
::获取保存目录
for %%a in ("%outputpath%") do set var=%%~dpa
set outputpath_folder=%var:~0,-1%
::拉取文件
call log %logger% I 正在拉取%filepath%到%outputpath%
cd /d %outputpath_folder% || ECHOC {%c_e%}进入目录%outputpath_folder%失败{%c_i%}{\n}&& call log %logger% F 进入目录%outputpath_folder%失败&& goto FATAL
adb.exe pull %filepath% %outputpath_fullname% 1>>%logfile% 2>&1 || cd /d %framework_workspace%&& ECHOC {%c_e%}拉取%filepath%到%outputpath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 拉取%filepath%到%outputpath%失败&& pause>nul && ECHO.重试... && goto ADBPULL-1
cd /d %framework_workspace% || ECHOC {%c_e%}进入目录%framework_workspace%失败{%c_i%}{\n}&& goto FATAL
::完成
call log %logger% I 拉取%filepath%到%outputpath%完成
ENDLOCAL
goto :eof


:QCDIAG
SETLOCAL
set logger=read.bat-qcdiag
::接收变量
set port=%args2%& set filepath=%args3%& set mode=%args4%
call log %logger% I 接收变量:port:%port%.filepath:%filepath%.mode:%mode%
:QCDIAG-1
::获取文件名
for %%a in ("%filepath%") do set filepath_fullname=%%~nxa
::检查qcn所在目录, qcn是否存在
for %%a in ("%filepath%") do set var=%%~dpa
set filepath_folder=%var:~0,-1%
if not exist %filepath_folder% ECHOC {%c_e%}找不到%filepath_folder%{%c_i%}{\n}& call log %logger% F 找不到%filepath_folder%& goto FATAL
if exist %filepath% (if not "%mode%"=="noprompt" ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
::如果端口号为auto则自动检查端口
if "%port%"=="auto" call chkdev qcdiag 1>nul
if "%port%"=="auto" set port=%chkdev__port__qcdiag%
::开始读出qcn
call log %logger% I 开始回读QCN到%filepath%
QCNTool.exe -r -p %port% -f %filepath_folder% -n %filepath_fullname% 1>%tmpdir%\output.txt 2>&1
::注意: 原始输出中包含设备IMEI, 如不希望将原始输出保存到日志, 请将下面一行type命令注释掉
type %tmpdir%\output.txt>>%logfile%
find "Reading QCN from phone... OK" "%tmpdir%\output.txt" 1>nul 2>nul || ECHOC {%c_e%}回读QCN到%filepath%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 回读QCN到%filepath%失败&& pause>nul && ECHO.重试... && goto QCDIAG-1
call log %logger% I 回读QCN到%filepath%完成
ENDLOCAL
goto :eof


:QCEDL
SETLOCAL
set logger=read.bat-qcedl
::接收变量
set parname=%args2%& set filepath=%args3%& set mode=%args4%& set port=%args5%& set fh=%args6%
call log %logger% I 接收变量:parname:%parname%.filepath:%filepath%.mode:%mode%.port:%port%.fh:%fh%
:QCEDL-1
::获取文件名
for %%a in ("%filepath%") do set filepath_fullname=%%~nxa
::检查img所在目录和img是否存在
for %%a in ("%filepath%") do set var=%%~dpa
set filepath_folder=%var:~0,-1%
if not exist %filepath_folder% ECHOC {%c_e%}找不到%filepath_folder%{%c_i%}{\n}& call log %logger% F 找不到%filepath_folder%& goto FATAL
if exist %filepath% (if not "%mode%"=="noprompt" ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
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
::找到目标分区, 开始回读
call log %logger% I 正在9008回读%filepath%.lun:%num%.起始扇区:%parstartsec%.扇区数目:%parsizesec%
::由于部分设备只能使用xml回读, 故生成xml
echo.^<?xml version="1.0" ?^>^<data^>^<program filename="%filepath_fullname%" physical_partition_number="%num%" label="%parname%" start_sector="%parstartsec%" num_partition_sectors="%parsizesec%" SECTOR_SIZE_IN_BYTES="%info__qcedl__secsize%" sparse="false"/^>^</data^>>%tmpdir%\tmp.xml
call read qcedlxml %port% %info__qcedl__memtype% %filepath_folder% %tmpdir%\tmp.xml
call log %logger% I 9008回读完成
ENDLOCAL
goto :eof


:QCEDLXML
SETLOCAL
set logger=read.bat-qcedlxml
::接收变量
set port=%args2%& set memory=%args3%& set folderpath=%args4%& set xml=%args5%& set fh=%args6%
call log %logger% I 接收变量:port:%port%.memory:%memory%.folderpath:%folderpath%.xml:%xml%.fh:%fh%
:QCEDLXML-1
::检查保存目录是否存在
if not exist %folderpath% ECHOC {%c_e%}找不到%folderpath%{%c_i%}{\n}& call log %logger% F 找不到%folderpath%& goto FATAL
::处理xml
echo.%xml%>%tmpdir%\output.txt
for /f %%a in ('busybox.exe sed "s/\//,/g" %tmpdir%\output.txt') do set xml=%%a
call log %logger% I xml参数更新为:
echo.%xml%>>%logfile%
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
::开始回读
call log %logger% I 正在9008回读
fh_loader.exe --port=\\.\COM%port% --memoryname=%memory% --sendxml=%xml% --convertprogram2read --mainoutputdir=%folderpath% --skip_config --showpercentagecomplete --noprompt 1>>%logfile% 2>&1 || ECHOC {%c_e%}9008回读失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 9008回读失败&& pause>nul && ECHO.重试... && goto QCEDLXML-1
move /Y %folderpath%\port_trace.txt %tmpdir% 1>>%logfile% 2>&1
call log %logger% I 9008回读完成
ENDLOCAL
goto :eof


:SYSTEM
SETLOCAL
set logger=read.bat-system
set target=./sdcard
goto ADBDD


:RECOVERY
SETLOCAL
set logger=read.bat-recovery
set target=./tmp
goto ADBDD


:ADBDD
::接收变量
set parname=%args2%& set filepath=%args3%& set mode=%args4%
call log %logger% I 接收变量:parname:%parname%.filepath:%filepath%.mode:%mode%
:ADBDD-1
::检查目录
::if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
if exist %filepath% (if not "%mode%"=="noprompt" ECHOC {%c_w%}已存在%filepath%, 继续将覆盖此文件. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% W 已存在%filepath%.继续将覆盖此文件& pause>nul & ECHO.继续...)
::系统下要检查Root
if "%target%"=="./sdcard" (
    call log %logger% I 开始检查Root
    echo.su>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt
    adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}获取Root失败. 请检查是否已为Shell授权Root权限. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 获取Root失败&& pause>nul && ECHO.重试... && goto ADBDD-1)
::获取分区路径
call info par %parname%
::读出
if "%target%"=="./sdcard" echo.su>%tmpdir%\cmd.txt& echo.dd if=%info__par__path% of=%target%/%parname%.img >>%tmpdir%\cmd.txt
if "%target%"=="./tmp" echo.dd if=%info__par__path% of=%target%/%parname%.img >%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt
call log %logger% I 开始读出%parname%到%target%/%parname%.img
adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}读出%parname%到%target%/%parname%.img失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 读出%parname%到%target%/%parname%.img失败&& pause>nul && ECHO.重试... && goto ADBDD-1
::拉取
call log %logger% I 开始拉取%target%/%parname%.img到%filepath%
call read adbpull %target%/%parname%.img %filepath% noprompt
::清理
call log %logger% I 开始删除%target%/%parname%.img
if "%target%"=="./sdcard" echo.su>%tmpdir%\cmd.txt& echo.rm %target%/%parname%.img>>%tmpdir%\cmd.txt
if "%target%"=="./tmp" echo.rm %target%/%parname%.img>%tmpdir%\cmd.txt
echo.exit>>%tmpdir%\cmd.txt& echo.exit>>%tmpdir%\cmd.txt
adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%target%/%parname%.img失败.{%c_i%}{\n}&& call log %logger% E 删除%target%/%parname%.img失败
ENDLOCAL
goto :eof









:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)

