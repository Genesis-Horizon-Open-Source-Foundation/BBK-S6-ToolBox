::修改: n

::call scrcpy 标题 wait(可选)
::            

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9

SETLOCAL
set logger=scrcpy.bat
set title=%args1%
if "%title%"=="" set title=BFF-ADB投屏
set wait=%args2%
call log %logger% I 接收变量:title:%title%.wait:%wait%
goto START

:START
call log %logger% I 开始ADB投屏
taskkill /f /im scrcpy.exe 1>>%logfile% 2>&1
::taskkill /f /im adb.exe 1>>%logfile% 2>&1
if "%wait%"=="wait" (
    %framework_workspace%\tool\Win\scrcpy\scrcpy.exe --show-touches --stay-awake --no-audio --no-audio-playback --window-title=%title% 1>>%logfile% 2>&1 || ECHOC {%c_e%}启动scrcpy失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 启动scrcpy失败&& pause>nul && ECHO.重试... && goto START
    taskkill /f /im scrcpy.exe 1>>%logfile% 2>&1)
if not "%wait%"=="wait" (
    echo.%framework_workspace%\tool\Win\scrcpy\scrcpy.exe --show-touches --stay-awake --no-audio --no-audio-playback --window-title=%title% 1^>^>%framework_workspace%\log\scrcpy.log 2^>^&1 >%tmpdir%\cmd.bat
    echo.taskkill /f /im scrcpy.exe 1^>^>%framework_workspace%\log\scrcpy.log 2^>^&1 >>%tmpdir%\cmd.bat
    echo.Set ws = CreateObject^("Wscript.Shell"^)>%tmpdir%\hide.vbs
    echo.ws.run "cmd /c %tmpdir%\cmd.bat",vbhide>>%tmpdir%\hide.vbs
    start %tmpdir%\hide.vbs)
call log %logger% I 退出scrcpy.bat
ENDLOCAL
goto :eof





:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
