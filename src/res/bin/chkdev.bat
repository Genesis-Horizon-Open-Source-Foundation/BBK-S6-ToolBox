::修改: n

::call chkdev system       rechk(可选)  复查前等待秒数(默认3)
::            recovery     rechk(可选)  复查前等待秒数(默认3)
::            sideload     rechk(可选)  复查前等待秒数(默认3)
::            fastboot     rechk(可选)  复查前等待秒数(默认3)
::            fastbootd    rechk(可选)  复查前等待秒数(默认3)
::            qcedl        rechk(可选)  复查前等待秒数(默认3)
::            qcdiag       rechk(可选)  复查前等待秒数(默认3)
::            sprdboot     rechk(可选)  复查前等待秒数(默认3)
::            mtkbrom      rechk(可选)  复查前等待秒数(默认3)
::            mtkpreloader rechk(可选)  复查前等待秒数(默认3)
::            all          rechk(可选)  复查前等待秒数(默认3)

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9


SETLOCAL
set mode=%args1%
if "%args2%"=="rechk" (set rechk=y) else (set rechk=n)
if not "%args3%"=="" (set rechk_wait=%args3%) else (set rechk_wait=3)
::如果没有检测到设备, 每次检测后会等待1秒再进行下一次检测. 此处设置每轮检测最多检测次数, 超过次数则暂停 (端口检测不等待且无限循环, 不受此限制).
set trytimes_max=30
set logger=chkdev.bat-%mode%
if not "%mode%"=="all" (goto CHKDEV-1) else (goto CHKDEV-2)
:CHKDEV-1
set keyword=
if "%mode%"=="system" set chktype=adb& set modename=系统& set keyword=device
if "%mode%"=="recovery" set chktype=adb& set modename=Recovery模式& set keyword=recovery
if "%mode%"=="sideload" set chktype=adb& set modename=ADB Sideload模式& set keyword=sideload
if "%mode%"=="fastboot" set chktype=fastboot& set modename=Fastboot模式& set keyword=fastboot
if "%mode%"=="fastbootd" set chktype=fastboot& set modename=FastbootD模式& set keyword=fastboot
if "%mode%"=="qcedl" set chktype=port& set modename=9008模式
if "%mode%"=="qcdiag" set chktype=port& set modename=高通基带调试模式
if "%mode%"=="sprdboot" set chktype=port& set modename=展讯boot模式& set keyword=SPRD U2S Diag
if "%mode%"=="mtkbrom" set chktype=port& set modename=联发科brom模式& set keyword=MediaTek USB Port 
if "%mode%"=="mtkpreloader" set chktype=port& set modename=联发科preloader模式& set keyword= PreLoader USB VCOM 
if "%chktype%"=="" ECHOC {%c_e%}参数错误{%c_i%}{\n}& call log %logger% F 参数错误& goto FATAL
call :chk%chktype%
if "%rechk%"=="n" goto DONE
ECHO.%rechk_wait%秒后将再次检查, 请稍候...& TIMEOUT /T %rechk_wait% /NOBREAK>nul & call :chk%chktype%
goto DONE
:CHKDEV-2
call :chkall
if "%rechk%"=="n" goto DONE
ECHO.%rechk_wait%秒后将再次检查, 请稍候...& TIMEOUT /T %rechk_wait% /NOBREAK>nul & call :chkall
goto DONE


:chkport
ECHOC {%c_i%}正在检查设备连接: %modename%... {%c_i%}& call log %logger% I 正在检查设备连接:%mode%
set trytimes=1
::开始检查
:chkport-1
::检查大于指定次为未连接
::if %trytimes% GTR %trytimes_max% ECHOC {%c_e%}未连接{%c_i%}{\n}& ECHOC {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备未连接:%mode%& pause>nul & goto chkport
::列表设备
if "%mode%"=="qcedl"  devcon.exe listclass Ports 2>&1 | busybox egrep -n "Qualcomm HS-USB QDLoader 9008|Quectel QDLoader 9008" | find /n ":" 1>%tmpdir%\output.txt 2>&1
if "%mode%"=="qcdiag" devcon.exe listclass Ports 2>&1 | busybox egrep -n "Qualcomm HS-USB Android DIAG 901D|Qualcomm HS-USB Diagnostics|Qualcomm HS-USB MDM Diagnostics|ZTE Handset Diagnostic Interface|LGE Mobile USB Diagnostic Port|USB Diagnostics Port" | find /n ":" 1>%tmpdir%\output.txt 2>&1
if not "%mode%"=="qcedl" (
    if not "%mode%"=="qcdiag" (
        devcon.exe listclass Ports 2>&1 | busybox egrep -n "%keyword%" | find /n ":" 1>%tmpdir%\output.txt 2>&1))
::检查是否只有一个设备
find "[1]" "%tmpdir%\output.txt" 1>nul 2>nul || set /a trytimes+=1&& goto chkport-1
find "[2]" "%tmpdir%\output.txt" 1>nul 2>nul && ECHOC {%c_we%} {%c_we%}{\n}&& type %tmpdir%\output.txt && ECHOC {%c_e%}有多个目标设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile%&& call log %logger% E 有多个目标设备连接&& pause>nul && ECHOC {%c_i%}重试...{%c_i%}&& goto chkport-1
::读取端口号
busybox.exe sed -i "s/ /\r\n/g" %tmpdir%\output.txt
set port=
for /f "tokens=1 delims=(COM) " %%a in ('type %tmpdir%\output.txt ^| find "(COM"') do set port=%%a
if "%port%"=="" call log %logger% E 读取目标设备端口号失败& goto chkport-1
::已连接
ECHOC {%c_s%}已连接 (COM%port%){%c_i%}{\n}& call log %logger% I 设备已连接:%mode%.端口号:%port%
goto :eof


:chkadb
ECHOC {%c_i%}正在检查设备连接: %modename%... {%c_i%}& call log %logger% I 正在检查设备连接:%mode%
adb.exe start-server 1>>%logfile% 2>&1 || ECHO. && ECHOC {%c_e%}启动adb服务失败. 请退出其他占用adb的软件. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 启动adb服务失败&& pause>nul && goto chkadb
set trytimes=1
::开始检查
:chkadb-1
::检查大于指定次为未连接
if %trytimes% GTR %trytimes_max% ECHOC {%c_e%}未连接{%c_i%}{\n}& ECHOC {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备未连接:%mode%& pause>nul & goto chkadb
::列表设备
adb.exe devices -l 2>&1 | find /v "List of devices attached" | find "%keyword%" | find /n "%keyword%" 1>%tmpdir%\output.txt 2>&1
::检查是否只有一个设备
set num=
for /f "tokens=1 delims=[]" %%a in (%tmpdir%\output.txt) do set num=%%a
if "%num%"=="" set /a trytimes+=1& TIMEOUT /T 1 /NOBREAK>nul & goto chkadb-1
if not "%num%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& type %tmpdir%\output.txt & ECHOC {%c_e%}有多个ADB设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& type %tmpdir%\output.txt>>%logfile%& call log %logger% E 有多个ADB设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkadb-1
::已连接
ECHOC {%c_s%}已连接{%c_i%}{\n}& call log %logger% I 设备已连接:%mode%
goto :eof


:chkfastboot
ECHOC {%c_i%}正在检查设备连接: %modename%... {%c_i%}& call log %logger% I 正在检查设备连接:%mode%
set trytimes=1
::开始检查
:chkfastboot-1
::检查大于指定次为未连接
if %trytimes% GTR %trytimes_max% ECHOC {%c_e%}未连接{%c_i%}{\n}& ECHOC {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备未连接:%mode%& pause>nul & goto chkfastboot
::列表设备
fastboot.exe devices -l 2>&1 | find "%keyword%" | find /n "%keyword%" 1>%tmpdir%\output.txt 2>&1
::检查是否只有一个设备
set num=
for /f "tokens=1 delims=[]" %%a in (%tmpdir%\output.txt) do set num=%%a
if "%num%"=="" set /a trytimes+=1& TIMEOUT /T 1 /NOBREAK>nul & goto chkfastboot-1
if not "%num%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& type %tmpdir%\output.txt & ECHOC {%c_e%}有多个Fastboot设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& type %tmpdir%\output.txt>>%logfile%& call log %logger% E 有多个Fastboot设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkfastboot-1
::区分fastboot和fastbootd
set var=n
fastboot.exe getvar is-userspace 2>&1 | find /v "Finished." | find "is-userspace: yes" 1>nul 2>nul && set var=y
if "%mode%"=="fastboot" (if "%var%"=="y" set /a trytimes+=1& TIMEOUT /T 1 /NOBREAK>nul & goto chkfastboot-1)
if "%mode%"=="fastbootd" (if "%var%"=="n" set /a trytimes+=1& TIMEOUT /T 1 /NOBREAK>nul & goto chkfastboot-1)
::已连接
ECHOC {%c_s%}已连接{%c_i%}{\n}& call log %logger% I 设备已连接:%mode%
goto :eof


:chkall
ECHOC {%c_i%}正在检查设备连接: 全部... {%c_i%}& call log %logger% I 正在检查设备连接:全部
adb.exe start-server 1>>%logfile% 2>&1 || ECHO. && ECHOC {%c_e%}启动adb服务失败. 请退出其他占用adb的软件. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 启动adb服务失败&& pause>nul && goto chkall
set trytimes=1
::开始检查
:chkall-1
set devnum=0
::检查大于指定次为未连接
if %trytimes% GTR %trytimes_max% ECHOC {%c_e%}未连接{%c_i%}{\n}& ECHOC {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 设备未连接:全部& pause>nul & goto chkall
::列表端口设备
devcon.exe listclass Ports 2>&1 | busybox.exe grep -E "Qualcomm HS-USB QDLoader 9008|Quectel QDLoader 9008|SPRD U2S Diag|MediaTek USB Port | PreLoader USB VCOM " 2>>%logfile% | find /N "COM" 1>%tmpdir%\output.txt 2>nul
::检查端口设备数是否大于1
set num=
for /f "tokens=1 delims=[] " %%a in (%tmpdir%\output.txt) do set num=%%a
if "%num%"=="" goto chkall-3
if not "%num%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& ECHOC {%c_e%}有多个设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 有多个设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkall-1
::判断端口设备模式
find "MediaTek USB Port " "%tmpdir%\output.txt" 1>nul 2>nul && set /a devnum+=1&& set mode=mtkbrom&& set modename=联发科brom模式&& set chktype=port&& goto chkall-2
find " PreLoader USB VCOM " "%tmpdir%\output.txt" 1>nul 2>nul && set /a devnum+=1&& set mode=mtkpreloader&& set modename=联发科preloader模式&& set chktype=port&& goto chkall-2
find "Qualcomm HS-USB QDLoader 9008" "%tmpdir%\output.txt" 1>nul 2>nul && set /a devnum+=1&& set mode=qcedl&& set modename=9008模式&& set chktype=port&& goto chkall-2
find "Quectel QDLoader 9008" "%tmpdir%\output.txt" 1>nul 2>nul && set /a devnum+=1&& set mode=qcedl&& set modename=9008模式&& set chktype=port&& goto chkall-2
find "SPRD U2S Diag" "%tmpdir%\output.txt" 1>nul 2>nul && set /a devnum+=1&& set mode=sprdboot&& set modename=展讯boot模式&& set chktype=port&& goto chkall-2
goto chkall-3
:chkall-2
::读取端口号
busybox.exe sed -i "s/ /\r\n/g" %tmpdir%\output.txt
set port=
for /f "tokens=1 delims=(COM) " %%a in ('type %tmpdir%\output.txt ^| find "(COM"') do set port=%%a
if "%port%"=="" ECHOC {%c_e%}读取设备端口号失败{%c_i%}{\n}& call log %logger% F 读取设备端口号失败& goto FATAL
:chkall-3
::列表fastboot设备
fastboot.exe devices -l 2>&1 | find " fastboot" | find /n " fastboot" 1>%tmpdir%\output.txt 2>&1
::检查fastboot设备数是否大于1
set num=
for /f "tokens=1 delims=[] " %%a in (%tmpdir%\output.txt) do set num=%%a
if "%num%"=="" goto chkall-4
if not "%num%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& ECHOC {%c_e%}有多个设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 有多个设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkall-1
set /a devnum+=1
::判断fastboot设备模式
set mode=fastboot& set modename=Fastboot模式& set chktype=fastboot
fastboot.exe getvar is-userspace 2>&1 | find /v "Finished." | find "is-userspace: yes" 1>nul 2>nul && set mode=fastbootd&& set modename=Fastbootd 模式&& set chktype=fastboot
:chkall-4
::列表adb设备
adb.exe devices -l 2>&1 | find /v "List of devices attached" | find " " | find /n " " 1>%tmpdir%\output.txt 2>&1
::检查adb设备数是否大于1
set num=
for /f "tokens=1,3 delims=[] " %%a in (%tmpdir%\output.txt) do set num=%%a& set var=%%b
if "%num%"=="" goto chkall-5
if not "%num%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& ECHOC {%c_e%}有多个设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 有多个设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkall-1
::判断adb设备模式
if "%var%"=="device" set /a devnum+=1& set mode=system& set modename=系统& set chktype=adb
if "%var%"=="recovery" set /a devnum+=1& set mode=recovery& set modename=Recovery模式& set chktype=adb
if "%var%"=="sideload" set /a devnum+=1& set mode=sideload& set modename=ADB Sideload模式& set chktype=adb
:chkall-5
::检查三大模式设备总数是否等于1
if "%devnum%"=="0" set /a trytimes+=1& TIMEOUT /T 1 /NOBREAK>nul & goto chkall-1
if not "%devnum%"=="1" ECHOC {%c_we%} {%c_we%}{\n}& ECHOC {%c_e%}有多个设备连接. 请断开其他设备. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 有多个设备连接& pause>nul & ECHOC {%c_i%}重试...{%c_i%}& goto chkall-1
::已连接
if not "%chktype%"=="port" (ECHOC {%c_s%}已连接: %modename%{%c_i%}{\n}& call log %logger% I 设备已连接:%mode%) else (ECHOC {%c_s%}已连接: %modename% ^(COM%port%^){%c_i%}{\n}& call log %logger% I 设备已连接:%mode%.端口号:%port%)
goto :eof


:DONE
ENDLOCAL & set chkdev__mode=%mode%& set chkdev__port=%port%& set chkdev__port__%mode%=%port%
goto :eof








:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)

