::修改: n

::call framework  startpre     skiptoolchk(可选)
::                adbpre       [文件名 all]
::                theme        主题名
::                conf         配置文件名         变量名        变量值
::                logviewer    end
::                loadcsvconf  csv文件路径        [要加载的项]  [orig full](输出变量名格式)
::                chkdiskspace [盘符 cur]         要比较的大小

::start framework logviewer start                %logfile%


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%




:CHKDISKSPACE
SETLOCAL
set logger=framework.bat-chkdiskspace
set letter=%args2%& set sizetocompare=%args3%
call log %logger% I 接收变量:letter:%letter%.sizetocompare:%sizetocompare%
if not "%letter%"=="cur" goto CHKDISKSPACE-1
set letter=
for %%a in ("%framework_workspace%") do set letter=%%~da
:CHKDISKSPACE-1
if "%letter%"=="" ECHOC {%c_e%}盘符参数缺失或获取失败{%c_i%}{\n}& call log %logger% F 盘符参数缺失或获取失败& goto FATAL
call log %logger% I 将检查磁盘%letter%
busybox.exe df -k 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile% && ECHOC {%c_e%}列表磁盘失败{%c_i%}{\n}&& call log %logger% F 列表磁盘失败&& goto FATAL
type %tmpdir%\output.txt>>%logfile%
set spaceleft_kb=
for /f "tokens=4 delims= " %%a in ('find "%letter%" "%tmpdir%\output.txt"') do set spaceleft_kb=%%a
if "%spaceleft_kb%"=="" ECHOC {%c_e%}读取磁盘可用空间失败{%c_i%}{\n}& call log %logger% F 读取磁盘可用空间失败& goto FATAL
call calc m spaceleft nodec %spaceleft_kb% 1024
call calc numcomp %spaceleft% %sizetocompare%
if "%calc__numcomp__result%"=="greater" (set enough=y) else (set enough=n)
call log %logger% I 空间是否足够:%enough%.磁盘可用空间:%spaceleft%.目标大小:%sizetocompare%
ENDLOCAL & set framework__chkdiskspace__enough=%enough%& set framework__chkdiskspace__spaceleft=%spaceleft%
goto :eof


:LOADCSVCONF
SETLOCAL
set logger=framework.bat-loadcsvconf
set filepath=%args2%& set item=%args3%& set mode=%args4%
call log %logger% I 接收变量:filepath:%filepath%.item:%item%.mode:%mode%
if not exist %filepath% ECHOC {%c_e%}找不到%filepath%{%c_i%}{\n}& call log %logger% F 找不到%filepath%& goto FATAL
if exist %tmpdir%\loadcsvconf.bat del %tmpdir%\loadcsvconf.bat 1>>%logfile% 2>&1
find "%item%" "%filepath%" 1>nul 2>nul || ECHOC {%c_e%}在%filepath%中找不到项目%item%{%c_i%}{\n}&& call log %logger% F 在%filepath%中找不到项目%item%&& goto FATAL
set num=2
:LOADCSVCONF-1
if %num% GTR 31 ECHOC {%c_e%}配置项目过多, 超出命令可容纳范围. 请向开发者反馈此问题{%c_i%}{\n}& call log %logger% F 配置项目过多:%num%个.超出命令可容纳范围:31个& goto FATAL
set name=
for /f "tokens=%num% delims=[]," %%a in ('type %filepath% ^| find "],["') do set name=%%a
if "%name%"=="" goto LOADCSVCONF-2
for /f "tokens=%num% delims=," %%a in ('type %filepath% ^| find "%item%"') do set value=%%a
if "%mode%"=="orig" echo.set %name%=%value%|find "set" 1>>%tmpdir%\loadcsvconf.bat
if not "%mode%"=="orig" echo.set framework__loadcsvconf__%name%=%value%|find "set" 1>>%tmpdir%\loadcsvconf.bat
set /a num+=1& goto LOADCSVCONF-1
:LOADCSVCONF-2
ENDLOCAL
call %tmpdir%\loadcsvconf.bat
goto :eof


:LOGVIEWER
if "%args2%"=="end" taskkill /f /im busybox-bfflogviewer.exe 1>nul 2>nul & goto :eof
@ECHO OFF
COLOR 0F
TITLE BFF-实时日志监控 [本窗口只监控日志, 不参与脚本运行]
ECHO.
ECHO.当前日志文件: %logfile%
ECHO.
call tool\Win\resizecmdwindow.exe -l 0 -r 70 -t 0 -b 20 -w 500 -h 800
tool\Win\busybox-bfflogviewer.exe tail -f %args3%
EXIT


:CONF
SETLOCAL
set logger=framework.bat-conf
call log %logger% I 将向conf\%args2%写入%args3%.值为%args4%
::if not exist conf\%args2% ECHOC {%c_e%}找不到conf\%args2%{%c_i%}{\n}& call log %logger% F 找不到conf\%args2%& goto FATAL
if not exist conf\%args2% echo.>conf\%args2%
find "set %args3%=" "conf\%args2%" 1>nul 2>nul || echo.set %args3%=%args4%|findstr "set" 1>>conf\%args2%&& goto CONF-DONE
type conf\%args2% | find "set " | find /v "set %args3%=" 1>%tmpdir%\output.txt
echo.set %args3%=%args4%|findstr "set" 1>>%tmpdir%\output.txt
move /Y %tmpdir%\output.txt conf\%args2% 1>nul || ECHOC {%c_e%}移动%tmpdir%\output.txt到conf\%args2%失败{%c_i%}{\n}&& call log %logger% F 移动%tmpdir%\output.txt到conf\%args2%失败&& goto FATAL
:CONF-DONE
ENDLOCAL
goto :eof


:THEME
set c_i=0F& set c_w=0E& set c_e=0C& set c_s=0A& set c_h=0D
if "%args2%"=="" set args2=%framework_theme%
if "%args2%"=="default" set c_i=0F& set c_w=0E& set c_e=0C& set c_s=0A& set c_h=0D& set c_a=0E& set c_we=07
if "%args2%"=="douyinhacker" set c_i=0A& set c_w=0E& set c_e=0C& set c_s=0F& set c_h=0D& set c_a=0E& set c_we=07
if "%args2%"=="ubuntu" set c_i=5F& set c_w=5E& set c_e=5C& set c_s=5A& set c_h=59& set c_a=5E& set c_we=5F
if "%args2%"=="classic" set c_i=3F& set c_w=3E& set c_e=3C& set c_s=3A& set c_h=3D& set c_a=3E& set c_we=3F
if "%args2%"=="gold" set c_i=8E& set c_w=E0& set c_e=CF& set c_s=A0& set c_h=6F& set c_a=8E& set c_we=8E
if "%args2%"=="dos" set c_i=1F& set c_w=1E& set c_e=1C& set c_s=A0& set c_h=80& set c_a=1E& set c_we=1F
if "%args2%"=="ChineseNewYear" set c_i=CF& set c_w=6F& set c_e=0F& set c_s=C0& set c_h=7C& set c_a=6F& set c_we=CF
goto :eof


:STARTPRE
if exist tool\logo.txt type tool\logo.txt
ECHO.正在准备启动...
::设置path-补充可能确缺少的系统环境路径...
set path=%path%||ECHO.系统环境变量的Path变量中存在错误的路径. 请更正后再试&& goto FATAL
set path=%path%;%windir%\Sysnative
::ECHO.检查find, findstr, copy, move, ren, del命令...
echo.test>bff_test1.tmp
find "test" "bff_test1.tmp"         1>nul || ECHO.执行find命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
findstr "test" "bff_test1.tmp"      1>nul || ECHO.执行findstr命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
copy /Y bff_test1.tmp bff_test2.tmp 1>nul || ECHO.执行copy命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
move /Y bff_test1.tmp bff_test2.tmp 1>nul || ECHO.执行move命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
ren bff_test2.tmp bff_test1.tmp     1>nul || ECHO.执行ren命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
del /F /Q bff_test1.tmp             1>nul || ECHO.执行del命令失败. 系统命令行环境存在问题, 或系统缺少必要组件&& goto FATAL
::ECHO.获取Windows版本号...
for /f "tokens=4 delims=[] " %%a in ('ver ^| find " "') do set winver=%%a
::ECHO.检查和保存工作目录路径...
for /f "tokens=2 delims=() " %%a in ('echo." %cd% "') do (if not "%%a"=="%cd%" ECHO.工具箱路径中不允许有空格或英文括号& goto FATAL)
set framework_workspace=%cd%
::ECHO.设置path-加入工具箱环境路径...
set path=%framework_workspace%;%framework_workspace%\tool\Win;%path%
::ECHO.检查ECHOC...
ECHOC | find "Usage" 1>nul 2>nul || ECHO.ECHOC.exe无法运行&& goto FATAL
::ECHO.检查gettime...
if not exist tool\Win\gettime.exe ECHOC {%c_e%}找不到gettime.exe{%c_i%}{\n}& goto FATAL
gettime.exe | find "." 1>nul 2>nul || ECHOC {%c_e%}gettime.exe无法运行{%c_i%}{\n}&& goto FATAL
::ECHO.准备tmp目录
if not exist tmp md tmp 1>nul || ECHOC {%c_e%}创建tmp文件夹失败{%c_i%}{\n}&& goto FATAL
if not "%framework_multitmpdir%"=="y" set framework_multitmpdir=n& set tmpdir=%framework_workspace%\tmp
if "%framework_multitmpdir%"=="y" (for /f %%a in ('gettime.exe ^| find "."') do set tmpdir=%framework_workspace%\tmp\%%a)
if not exist %tmpdir% md %tmpdir% 1>nul || ECHOC {%c_e%}创建%tmpdir%文件夹失败{%c_i%}{\n}&& goto FATAL
::ECHO.准备日志系统...
if not exist log.bat ECHOC {%c_e%}找不到log.bat{%c_i%}{\n}& goto FATAL
if "%framework_log%"=="n" set logfile=nul& set logger=CLOSED
if "%framework_log%"=="n" SETLOCAL & goto STARTPRE-2
if not exist log md log 1>nul || ECHOC {%c_e%}创建log文件夹失败{%c_i%}{\n}&& goto FATAL
for /f %%a in ('gettime.exe ^| find "."') do set logfile=%framework_workspace%\log\%%a.log
set logger=UNKNOWN
SETLOCAL
set logger=framework.bat-startpre
call log %logger% I 系统信息:%processor_architecture%.%winver%.工作目录:%framework_workspace%
::ECHO.清理日志...
if "%framework_lognum%"=="" set framework_lognum=6
for /f %%a in ('dir /B log ^| find /C ".log"') do (if %%a LEQ %framework_lognum% goto STARTPRE-2)
for /f "tokens=1 delims=[]" %%a in ('dir /B log ^| find /N ".log"') do set /a var=%%a-%framework_lognum%
:STARTPRE-1
dir /B log | find /N ".log" | find "[%var%]" 1>nul 2>nul || goto STARTPRE-2
for /f "tokens=2 delims=[]" %%a in ('dir /B log ^| find /N ".log" ^| find "[%var%]"') do del log\%%a 1>nul
set /a var+=-1& goto STARTPRE-1
:STARTPRE-2
if "%args2%"=="skiptoolchk" call log %logger% I 跳过检查工具& goto STARTPRE-DONE
::ECHO.检查calc.bat...
if not exist calc.bat ECHOC {%c_e%}找不到calc.bat{%c_i%}{\n}& call log %logger% F 找不到calc.bat& goto FATAL
::ECHO.检查chkdev.bat...
if not exist chkdev.bat ECHOC {%c_e%}找不到chkdev.bat{%c_i%}{\n}& call log %logger% F 找不到chkdev.bat& goto FATAL
::ECHO.检查clean.bat...
if not exist clean.bat ECHOC {%c_e%}找不到clean.bat{%c_i%}{\n}& call log %logger% F 找不到clean.bat& goto FATAL
::ECHO.检查dl.bat...
if not exist dl.bat ECHOC {%c_e%}找不到dl.bat{%c_i%}{\n}& call log %logger% F 找不到dl.bat& goto FATAL
::ECHO.检查imgkit.bat...
if not exist imgkit.bat ECHOC {%c_e%}找不到imgkit.bat{%c_i%}{\n}& call log %logger% F 找不到imgkit.bat& goto FATAL
::ECHO.检查info.bat...
if not exist info.bat ECHOC {%c_e%}找不到info.bat{%c_i%}{\n}& call log %logger% F 找不到info.bat& goto FATAL
::ECHO.检查input.bat...
if not exist input.bat ECHOC {%c_e%}找不到input.bat{%c_i%}{\n}& call log %logger% F 找不到input.bat& goto FATAL
::ECHO.检查open.bat...
if not exist open.bat ECHOC {%c_e%}找不到open.bat{%c_i%}{\n}& call log %logger% F 找不到open.bat& goto FATAL
::ECHO.检查partable.bat...
if not exist partable.bat ECHOC {%c_e%}找不到partable.bat{%c_i%}{\n}& call log %logger% F 找不到partable.bat& goto FATAL
::ECHO.检查random.bat...
if not exist random.bat ECHOC {%c_e%}找不到random.bat{%c_i%}{\n}& call log %logger% F 找不到random.bat& goto FATAL
::ECHO.检查read.bat...
if not exist read.bat ECHOC {%c_e%}找不到read.bat{%c_i%}{\n}& call log %logger% F 找不到read.bat& goto FATAL
::ECHO.检查reboot.bat...
if not exist reboot.bat ECHOC {%c_e%}找不到reboot.bat{%c_i%}{\n}& call log %logger% F 找不到reboot.bat& goto FATAL
::ECHO.检查scrcpy.bat...
if not exist scrcpy.bat ECHOC {%c_e%}找不到scrcpy.bat{%c_i%}{\n}& call log %logger% F 找不到scrcpy.bat& goto FATAL
::ECHO.检查sel.bat...
if not exist sel.bat ECHOC {%c_e%}找不到sel.bat{%c_i%}{\n}& call log %logger% F 找不到sel.bat& goto FATAL
::ECHO.检查slot.bat...
if not exist slot.bat ECHOC {%c_e%}找不到slot.bat{%c_i%}{\n}& call log %logger% F 找不到slot.bat& goto FATAL
::ECHO.检查write.bat...
if not exist write.bat ECHOC {%c_e%}找不到write.bat{%c_i%}{\n}& call log %logger% F 找不到write.bat& goto FATAL
::ECHO.检查360AblumViewer...
::if not exist tool\Win\360AblumViewer.exe ECHOC {%c_e%}找不到360AblumViewer.exe{%c_i%}{\n}& call log %logger% F 找不到360AblumViewer.exe& goto FATAL
::if not exist tool\Win\360AblumViewer.ini ECHOC {%c_e%}找不到360AblumViewer.ini{%c_i%}{\n}& call log %logger% F 找不到360AblumViewer.ini& goto FATAL
::ECHO.检查Notepad3...
if not exist tool\Win\Notepad3\Notepad3.exe ECHOC {%c_e%}找不到Notepad3.exe{%c_i%}{\n}& call log %logger% F 找不到Notepad3.exe& goto FATAL
::ECHO.检查scrcpy...
if not exist tool\Win\scrcpy\scrcpy.exe ECHOC {%c_e%}找不到scrcpy.exe{%c_i%}{\n}& call log %logger% F 找不到scrcpy.exe& goto FATAL
tool\Win\scrcpy\scrcpy.exe -h | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}scrcpy.exe无法运行{%c_i%}{\n}&& call log %logger% F scrcpy.exe无法运行&& goto FATAL
::ECHO.检查Vieas...
if not exist tool\Win\Vieas\Vieas.exe ECHOC {%c_e%}找不到Vieas.exe{%c_i%}{\n}& call log %logger% F 找不到Vieas.exe& goto FATAL
::ECHO.检查7z...
if not exist tool\Win\7z.dll ECHOC {%c_e%}找不到7z.dll{%c_i%}{\n}& call log %logger% F 找不到7z.dll& goto FATAL
if not exist tool\Win\7z.exe ECHOC {%c_e%}找不到7z.exe{%c_i%}{\n}& call log %logger% F 找不到7z.exe& goto FATAL
7z.exe | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}7z.exe无法运行{%c_i%}{\n}&& call log %logger% F 7z.exe无法运行&& goto FATAL
::ECHO.检查aapt...
::if not exist tool\Win\aapt.exe ECHOC {%c_e%}找不到aapt.exe{%c_i%}{\n}& call log %logger% F 找不到aapt.exe& goto FATAL
::tool\Win\aapt.exe v | find "Android" 1>nul 2>nul || ECHOC {%c_e%}aapt.exe无法运行{%c_i%}{\n}&& call log %logger% F aapt.exe无法运行&& goto FATAL
::ECHO.检查adb...
if not exist tool\Win\adb.exe ECHOC {%c_e%}找不到adb.exe{%c_i%}{\n}& call log %logger% F 找不到adb.exe& goto FATAL
if not exist tool\Win\AdbWinApi.dll ECHOC {%c_e%}找不到AdbWinApi.dll{%c_i%}{\n}& call log %logger% F 找不到AdbWinApi.dll& goto FATAL
if not exist tool\Win\AdbWinUsbApi.dll ECHOC {%c_e%}找不到AdbWinUsbApi.dll{%c_i%}{\n}& call log %logger% F 找不到AdbWinUsbApi.dll& goto FATAL
adb.exe start-server>nul
adb.exe devices | find "List of devices attached" 1>nul 2>nul || ECHOC {%c_e%}adb.exe无法运行{%c_i%}{\n}&& call log %logger% F adb.exe无法运行&& goto FATAL
::ECHO.检查aria2c...
if not exist tool\Win\aria2c.exe ECHOC {%c_e%}找不到aria2c.exe{%c_i%}{\n}& call log %logger% F 找不到aria2c.exe& goto FATAL
aria2c.exe -h | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}aria2c.exe无法运行{%c_i%}{\n}&& call log %logger% F aria2c.exe无法运行&& goto FATAL
::ECHO.检查busybox...
if not exist tool\Win\busybox.exe ECHOC {%c_e%}找不到busybox.exe{%c_i%}{\n}& call log %logger% F 找不到busybox.exe& goto FATAL
busybox.exe | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}busybox.exe无法运行{%c_i%}{\n}&& call log %logger% F busybox.exe无法运行&& goto FATAL
::ECHO.检查busybox-bfflogviewer...
if not exist tool\Win\busybox-bfflogviewer.exe ECHOC {%c_e%}找不到busybox-bfflogviewer.exe{%c_i%}{\n}& call log %logger% F 找不到busybox-bfflogviewer.exe& goto FATAL
busybox-bfflogviewer.exe | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}busybox-bfflogviewer.exe无法运行{%c_i%}{\n}&& call log %logger% F busybox-bfflogviewer.exe无法运行&& goto FATAL
::ECHO.检查calc...
if not exist tool\Win\calc.exe ECHOC {%c_e%}找不到calc.exe{%c_i%}{\n}& call log %logger% F 找不到calc.exe& goto FATAL
for /f %%a in ('calc.exe 2199023255552 m 999 6') do (if not "%%a"=="2196824232296448.000000" ECHOC {%c_e%}calc.exe无法运行{%c_i%}{\n}& call log %logger% F calc.exe无法运行& goto FATAL)
::ECHO.检查curl...
if not exist tool\Win\curl.exe ECHOC {%c_e%}找不到curl.exe{%c_i%}{\n}& call log %logger% F 找不到curl.exe& goto FATAL
curl.exe --help | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}curl.exe无法运行{%c_i%}{\n}&& call log %logger% F curl.exe无法运行&& goto FATAL
::ECHO.检查cygwin1.dll...
::if not exist tool\Win\cygwin1.dll ECHOC {%c_e%}找不到cygwin1.dll{%c_i%}{\n}& call log %logger% F 找不到cygwin1.dll& goto FATAL
::ECHO.检查devcon...
if not exist tool\Win\devcon.exe ECHOC {%c_e%}找不到devcon.exe{%c_i%}{\n}& call log %logger% F 找不到devcon.exe& goto FATAL
devcon.exe help | find "Device" 1>nul 2>nul || ECHOC {%c_e%}devcon.exe无法运行{%c_i%}{\n}&& call log %logger% F devcon.exe无法运行&& goto FATAL
::ECHO.检查fastboot...
if not exist tool\Win\fastboot.exe ECHOC {%c_e%}找不到fastboot.exe{%c_i%}{\n}& call log %logger% F 找不到fastboot.exe& goto FATAL
fastboot.exe -h 2>&1 | find "usage" 1>nul 2>nul || ECHOC {%c_e%}fastboot.exe无法运行{%c_i%}{\n}&& call log %logger% F fastboot.exe无法运行&& goto FATAL
::ECHO.检查fh_loader...
if not exist tool\Win\fh_loader.exe ECHOC {%c_e%}找不到fh_loader.exe{%c_i%}{\n}& call log %logger% F 找不到fh_loader.exe& goto FATAL
fh_loader.exe -6 2>&1 | find "Base" 1>nul 2>nul || ECHOC {%c_e%}fh_loader.exe无法运行{%c_i%}{\n}&& call log %logger% F fh_loader.exe无法运行&& goto FATAL
::ECHO.检查filedialog...
if not exist tool\Win\filedialog.exe ECHOC {%c_e%}找不到filedialog.exe{%c_i%}{\n}& call log %logger% F 找不到filedialog.exe& goto FATAL
filedialog.exe 2>&1 | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}filedialog.exe无法运行{%c_i%}{\n}&& call log %logger% F filedialog.exe无法运行&& goto FATAL
::ECHO.检查HexTool...
if not exist tool\Win\HexTool.exe ECHOC {%c_e%}找不到HexTool.exe{%c_i%}{\n}& call log %logger% F 找不到HexTool.exe& goto FATAL
HexTool.exe | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}HexTool.exe无法运行{%c_i%}{\n}&& call log %logger% F HexTool.exe无法运行&& goto FATAL
::ECHO.检查libcurl.def...
if not exist tool\Win\libcurl.def ECHOC {%c_e%}找不到libcurl.def{%c_i%}{\n}& call log %logger% F 找不到libcurl.def& goto FATAL
::ECHO.检查libcurl.dll...
if not exist tool\Win\libcurl.dll ECHOC {%c_e%}找不到libcurl.dll{%c_i%}{\n}& call log %logger% F 找不到libcurl.dll& goto FATAL
::ECHO.检查magiskboot...
if not exist tool\Win\magiskboot.exe ECHOC {%c_e%}找不到magiskboot.exe{%c_i%}{\n}& call log %logger% F 找不到magiskboot.exe& goto FATAL
magiskboot.exe 2>&1 | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}magiskboot.exe无法运行{%c_i%}{\n}&& call log %logger% F magiskboot.exe无法运行&& goto FATAL
::ECHO.检查magiskpatcher...
::if not exist tool\Win\magiskpatcher.exe ECHOC {%c_e%}找不到magiskpatcher.exe{%c_i%}{\n}& call log %logger% F 找不到magiskpatcher.exe& goto FATAL
::magiskpatcher.exe -h 2>&1 | find "usage" 1>nul 2>nul || ECHOC {%c_e%}magiskpatcher.exe无法运行{%c_i%}{\n}&& call log %logger% F magiskpatcher.exe无法运行&& goto FATAL
::ECHO.检查numcomp...
if not exist tool\Win\numcomp.exe ECHOC {%c_e%}找不到numcomp.exe{%c_i%}{\n}& call log %logger% F 找不到numcomp.exe& goto FATAL
numcomp.exe 999 888 | find "greater" 1>nul 2>nul || ECHOC {%c_e%}numcomp.exe无法运行{%c_i%}{\n}&& call log %logger% F numcomp.exe无法运行&& goto FATAL
::ECHO.检查ptanalyzer...
if not exist tool\Win\ptanalyzer.exe ECHOC {%c_e%}找不到ptanalyzer.exe{%c_i%}{\n}& call log %logger% F 找不到ptanalyzer.exe& goto FATAL
ptanalyzer.exe 2>&1 | find "ptanalyzer" 1>nul 2>nul || ECHOC {%c_e%}ptanalyzer.exe无法运行{%c_i%}{\n}&& call log %logger% F ptanalyzer.exe无法运行&& goto FATAL
::ECHO.检查qcedlxmlhelper...
if not exist tool\Win\qcedlxmlhelper.exe ECHOC {%c_e%}找不到qcedlxmlhelper.exe{%c_i%}{\n}& call log %logger% F 找不到qcedlxmlhelper.exe& goto FATAL
qcedlxmlhelper.exe 2>&1 | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}qcedlxmlhelper.exe无法运行{%c_i%}{\n}&& call log %logger% F qcedlxmlhelper.exe无法运行&& goto FATAL
::ECHO.检查QCNTool...
if not exist tool\Win\QCNTool.exe ECHOC {%c_e%}找不到QCNTool.exe{%c_i%}{\n}& call log %logger% F 找不到QCNTool.exe& goto FATAL
QCNTool.exe -h | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}QCNTool.exe无法运行{%c_i%}{\n}&& call log %logger% F QCNTool.exe无法运行&& goto FATAL
::ECHO.检查QMSL_MSVC10R.dll...
if not exist tool\Win\QMSL_MSVC10R.dll ECHOC {%c_e%}找不到QMSL_MSVC10R.dll{%c_i%}{\n}& call log %logger% F 找不到QMSL_MSVC10R.dll& goto FATAL
::ECHO.检查QSaharaServer...
if not exist tool\Win\QSaharaServer.exe ECHOC {%c_e%}找不到QSaharaServer.exe{%c_i%}{\n}& call log %logger% F 找不到QSaharaServer.exe& goto FATAL
QSaharaServer.exe | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}QSaharaServer.exe无法运行{%c_i%}{\n}&& call log %logger% F QSaharaServer.exe无法运行&& goto FATAL
::ECHO.检查resizecmdwindow...
if not exist tool\Win\resizecmdwindow.exe ECHOC {%c_e%}找不到resizecmdwindow.exe{%c_i%}{\n}& call log %logger% F 找不到resizecmdwindow.exe& goto FATAL
resizecmdwindow.exe | find "usage" 1>nul 2>nul || ECHOC {%c_e%}resizecmdwindow.exe无法运行{%c_i%}{\n}&& call log %logger% F resizecmdwindow.exe无法运行&& goto FATAL
::ECHO.检查simg_dump...
if not exist tool\Win\simg_dump.exe ECHOC {%c_e%}找不到simg_dump.exe{%c_i%}{\n}& call log %logger% F 找不到simg_dump.exe& goto FATAL
simg_dump.exe 2>&1 | find "Usage" 1>nul 2>nul || ECHOC {%c_e%}simg_dump.exe无法运行{%c_i%}{\n}&& call log %logger% F simg_dump.exe无法运行&& goto FATAL
::ECHO.检查strtofile...
if not exist tool\Win\strtofile.exe ECHOC {%c_e%}找不到strtofile.exe{%c_i%}{\n}& call log %logger% F 找不到strtofile.exe& goto FATAL
if exist %tmpdir%\bff-test.txt del %tmpdir%\bff-test.txt 1>nul
echo.bff-test|strtofile.exe %tmpdir%\bff-test.txt || ECHOC {%c_e%}strtofile.exe无法运行{%c_i%}{\n}&& call log %logger% F strtofile.exe无法运行&& goto FATAL
for /f %%a in (%tmpdir%\bff-test.txt) do (if not "%%a"=="bff-test" ECHOC {%c_e%}strtofile.exe无法运行{%c_i%}{\n}& call log %logger% F strtofile.exe无法运行& goto FATAL)
del %tmpdir%\bff-test.txt 1>nul
::ECHO.检查usbdump...
::if not exist tool\Win\usbdump.exe ECHOC {%c_e%}找不到usbdump.exe{%c_i%}{\n}& call log %logger% F 找不到usbdump.exe& goto FATAL
::usbdump.exe -v | find "." 1>nul 2>nul || ECHOC {%c_e%}usbdump.exe无法运行{%c_i%}{\n}&& call log %logger% F usbdump.exe无法运行&& goto FATAL
::ECHO.检查blktool...
if not exist tool\Android\blktool ECHOC {%c_e%}找不到blktool{%c_i%}{\n}& call log %logger% F 找不到blktool& goto FATAL
::ECHO.检查bootctl...
if not exist tool\Android\bootctl ECHOC {%c_e%}找不到bootctl{%c_i%}{\n}& call log %logger% F 找不到bootctl& goto FATAL
::ECHO.检查busybox...
if not exist tool\Android\busybox ECHOC {%c_e%}找不到busybox{%c_i%}{\n}& call log %logger% F 找不到busybox& goto FATAL
::ECHO.检查dmsetup...
if not exist tool\Android\dmsetup ECHOC {%c_e%}找不到dmsetup{%c_i%}{\n}& call log %logger% F 找不到dmsetup& goto FATAL
::ECHO.检查misc_tofastboot.img...
::if not exist tool\Android\misc_tofastboot.img ECHOC {%c_e%}找不到misc_tofastboot.img{%c_i%}{\n}& call log %logger% F 找不到misc_tofastboot.img& goto FATAL
::ECHO.检查misc_torecovery.img...
::if not exist tool\Android\misc_torecovery.img ECHOC {%c_e%}找不到misc_torecovery.img{%c_i%}{\n}& call log %logger% F 找不到misc_torecovery.img& goto FATAL
::ECHO.检查mke2fs...
if not exist tool\Android\mke2fs ECHOC {%c_e%}找不到mke2fs{%c_i%}{\n}& call log %logger% F 找不到mke2fs& goto FATAL
::ECHO.检查mkfs.exfat...
if not exist tool\Android\mkfs.exfat ECHOC {%c_e%}找不到mkfs.exfat{%c_i%}{\n}& call log %logger% F 找不到mkfs.exfat& goto FATAL
::ECHO.检查mkfs.fat...
if not exist tool\Android\mkfs.fat ECHOC {%c_e%}找不到mkfs.fat{%c_i%}{\n}& call log %logger% F 找不到mkfs.fat& goto FATAL
::ECHO.检查mkntfs...
if not exist tool\Android\mkntfs ECHOC {%c_e%}找不到mkntfs{%c_i%}{\n}& call log %logger% F 找不到mkntfs& goto FATAL
::ECHO.检查parted...
if not exist tool\Android\parted ECHOC {%c_e%}找不到parted{%c_i%}{\n}& call log %logger% F 找不到parted& goto FATAL
::ECHO.检查sgdisk...
if not exist tool\Android\sgdisk ECHOC {%c_e%}找不到sgdisk{%c_i%}{\n}& call log %logger% F 找不到sgdisk& goto FATAL
:STARTPRE-DONE
call log %logger% I 启动准备工作完成
ENDLOCAL
goto :eof


:ADBPRE
call log framework.bat-adbpre I 接收变量:args2:%args2%
if "%args2%"=="" set args2=all
if "%args2%"=="all" (
    call write adbpush tool\Android\blktool blktool program
    call write adbpush tool\Android\bootctl bootctl program
    call write adbpush tool\Android\busybox busybox program
    call write adbpush tool\Android\dmsetup dmsetup program
    call write adbpush tool\Android\mke2fs mke2fs program
    call write adbpush tool\Android\mkfs.exfat mkfs.exfat program
    call write adbpush tool\Android\mkfs.fat mkfs.fat program
    call write adbpush tool\Android\mkntfs mkntfs program
    call write adbpush tool\Android\parted parted program
    call write adbpush tool\Android\sgdisk sgdisk program)
if not "%args2%"=="all" call write adbpush tool\Android\%args2% %args2% program
goto :eof





:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
