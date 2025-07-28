::修改: n

::call slot [system recovery fastboot fastbootd auto] set [a b cur cur_oth]
::          [system recovery fastboot fastbootd auto] chk

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
SETLOCAL
set logger=slot.bat
set devmode=%args1%& set func=%args2%& set target=%args3%
call log %logger% I 接收变量:devmode:%devmode%.func:%func%.target:%target%
::目标槽位大写转小写
if "%target%"=="A" set target=a
if "%target%"=="B" set target=b
::自动识别设备模式
if "%devmode%"=="auto" call chkdev all
if "%devmode%"=="auto" set devmode=%chkdev__mode%
::处理跳转
if "%devmode%"=="system" goto CHK-ADB
if "%devmode%"=="recovery" goto CHK-ADB
if "%devmode%"=="fastboot" goto CHK-FASTBOOT
if "%devmode%"=="fastbootd" goto CHK-FASTBOOT
ECHOC {%c_e%}%devmode%模式不支持槽位功能{%c_i%}{\n}& call log %logger% F %devmode%模式不支持槽位功能& goto FATAL


:CHK-ADB
set slot_cur=
call log %logger% I 开始ADB读取ro.boot.slot_suffix
for /f "tokens=1 delims=_ " %%a in ('adb.exe shell getprop ro.boot.slot_suffix') do set slot_cur=%%a
call log %logger% I ADB读取ro.boot.slot_suffix结果为:%slot_cur%
::if "%devmode%"=="system" echo.su>%tmpdir%\cmd.txt& echo.cat /proc/cmdline>>%tmpdir%\cmd.txt
::if "%devmode%"=="recovery" echo.cat /proc/cmdline>%tmpdir%\cmd.txt
::call log %logger% I 开始ADB读取/proc/cmdline
::adb.exe shell < %tmpdir%\cmd.txt 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}ADB读取/proc/cmdline失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile%&& call log %logger% E ADB读取/proc/cmdline失败&& pause>nul && ECHO.重试... && goto CHK-ADB
::type %tmpdir%\output.txt>>%logfile%
::set slot_cur=
::find "androidboot.slot_suffix=_a" "%tmpdir%\output.txt" 1>nul 2>nul && set slot_cur=a
::find "androidboot.slot_suffix=_b" "%tmpdir%\output.txt" 1>nul 2>nul && set slot_cur=b
::find "androidboot.slot_suffix=a" "%tmpdir%\output.txt" 1>nul 2>nul && set slot_cur=a
::find "androidboot.slot_suffix=b" "%tmpdir%\output.txt" 1>nul 2>nul && set slot_cur=b
if "%slot_cur%"=="a" set slot_cur_oth=b& goto CHK-ADB-1
if "%slot_cur%"=="b" set slot_cur_oth=a& goto CHK-ADB-1
ECHOC {%c_e%}读取槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 读取槽位信息失败& pause>nul & ECHO.重试... & goto CHK-ADB
:CHK-ADB-1
call log %logger% I ADB读取到槽位信息:slot_cur:%slot_cur%.slot_cur_oth:%slot_cur_oth%
::读取完成
if not "%func%"=="set" ENDLOCAL & set slot__cur=%slot_cur%& set slot__cur_oth=%slot_cur_oth%& goto :eof
goto SET-ADB
:SET-ADB
if "%target%"=="cur" set target=%slot_cur%
if "%target%"=="cur_oth" set target=%slot_cur_oth%
if "%target%"=="a" set var=0
if "%target%"=="b" set var=1
call framework adbpre bootctl
if "%devmode%"=="system" echo.su>%tmpdir%\cmd.txt& echo../data/local/tmp/bootctl set-active-boot-slot %var% >>%tmpdir%\cmd.txt
if "%devmode%"=="recovery" echo.bootctl set-active-boot-slot %var% >%tmpdir%\cmd.txt & 
call log %logger% I 开始ADB设置槽位为%target%(%var%)
adb.exe shell < %tmpdir%\cmd.txt 1>>%logfile% 2>&1 || ECHOC {%c_e%}ADB设置槽位为%target%(%var%)失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E ADB设置槽位为%target%(%var%)失败&& pause>nul && ECHO.重试... && goto SET-ADB
call log %logger% I ADB成功设置槽位为%target%(%var%)
ECHO.成功设置槽位为%target%
ENDLOCAL
goto :eof


:CHK-FASTBOOT
call log %logger% I 开始Fastboot读取槽位信息
fastboot.exe getvar current-slot 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}Fastboot读取槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile%&& call log %logger% E Fastboot读取槽位信息失败&& pause>nul && ECHO.重试... && goto CHK-FASTBOOT
type %tmpdir%\output.txt>>%logfile%
set slot_cur=
for /f "tokens=2 delims=_ " %%i in ('type %tmpdir%\output.txt ^| find "slot"') do set slot_cur=%%i
if "%slot_cur%"=="" ECHOC {%c_e%}查找槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 查找槽位信息失败& pause>nul & ECHO.重试... & goto CHK-FASTBOOT
if "%slot_cur%"=="a" set slot_cur_oth=b
if "%slot_cur%"=="b" set slot_cur_oth=a
::读取能否启动信息
fastboot.exe getvar all 2>&1| find "slot-unbootable:" 1>%tmpdir%\output.txt 2>&1 || ECHOC {%c_e%}Fastboot读取槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& type %tmpdir%\output.txt>>%logfile%&& call log %logger% E Fastboot读取槽位信息失败&& pause>nul && ECHO.重试... && goto CHK-FASTBOOT
type %tmpdir%\output.txt>>%logfile%
set slot_a_unbootable=
for /f "tokens=4 delims=: " %%i in ('type %tmpdir%\output.txt ^| find "slot-unbootable:_a"') do set slot_a_unbootable=%%i
for /f "tokens=4 delims=: " %%i in ('type %tmpdir%\output.txt ^| find "slot-unbootable:a"') do set slot_a_unbootable=%%i
if "%slot_a_unbootable%"=="" ECHOC {%c_e%}查找槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 查找槽位信息失败& pause>nul & ECHO.重试... & goto CHK-FASTBOOT
set slot_b_unbootable=
for /f "tokens=4 delims=: " %%i in ('type %tmpdir%\output.txt ^| find "slot-unbootable:_b"') do set slot_b_unbootable=%%i
for /f "tokens=4 delims=: " %%i in ('type %tmpdir%\output.txt ^| find "slot-unbootable:b"') do set slot_b_unbootable=%%i
if "%slot_b_unbootable%"=="" ECHOC {%c_e%}查找槽位信息失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 查找槽位信息失败& pause>nul & ECHO.重试... & goto CHK-FASTBOOT
if "%slot_cur%"=="a" set slot_cur_unbootable=%slot_a_unbootable%& set slot_cur_oth_unbootable=%slot_b_unbootable%
if "%slot_cur%"=="b" set slot_cur_unbootable=%slot_b_unbootable%& set slot_cur_oth_unbootable=%slot_a_unbootable%
call log %logger% I Fastboot读取到槽位信息:slot_cur:%slot_cur%.slot_cur_oth:%slot_cur_oth%.slot_cur_unbootable:%slot_cur_unbootable%.slot_cur_oth_unbootable:%slot_cur_oth_unbootable%.slot_a_unbootable:%slot_a_unbootable%.slot_b_unbootable:%slot_b_unbootable%
::读取完成
if not "%func%"=="set" ENDLOCAL & set slot__cur=%slot_cur%& set slot__cur_oth=%slot_cur_oth%& set slot__cur_unbootable=%slot_cur_unbootable%& set slot__cur_oth_unbootable=%slot_cur_oth_unbootable%& set slot__a_unbootable=%slot_a_unbootable%& set slot__b_unbootable=%slot_b_unbootable%& goto :eof
goto SET-FASTBOOT
:SET-FASTBOOT
if "%target%"=="cur" set target=%slot_cur%
if "%target%"=="cur_oth" set target=%slot_cur_oth%
if "%target%"=="a" (if "%slot_a_unbootable%"=="yes" ECHOC {%c_w%}警告: 目标槽位%target%被标记为不可启动, 切换后可能出现无法启动等问题. {%c_i%}将切换到槽位%target%...{%c_i%}{\n}& call log %logger% W 目标槽位%target%被标记为不可启动)
if "%target%"=="b" (if "%slot_b_unbootable%"=="yes" ECHOC {%c_w%}警告: 目标槽位%target%被标记为不可启动, 切换后可能出现无法启动等问题. {%c_i%}将切换到槽位%target%...{%c_i%}{\n}& call log %logger% W 目标槽位%target%被标记为不可启动)
call log %logger% I 开始Fastboot设置槽位为%target%
fastboot.exe set_active %target% 1>>%logfile% 2>&1 || ECHOC {%c_e%}Fastboot设置槽位为%target%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E Fastboot设置槽位为%target%失败&& pause>nul && ECHO.重试... && goto SET-FASTBOOT
call log %logger% I Fastboot成功设置槽位为%target%
ECHO.成功设置槽位为%target%
ENDLOCAL
goto :eof




:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)

