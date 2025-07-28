::修改: n

::call log %logger% I 文字
::                  W
::                  E
::                  F

@ECHO OFF
if "%framework_log%"=="n" goto :eof
SETLOCAL
for /f %%a in ('gettime.exe') do set logtext=%%a [%2] %1 %3
if not "%logfile%"=="" (if not "%logfile%"=="nul" echo.%logtext% >>%logfile% & ENDLOCAL & goto :eof)
ECHO.%logtext% & ENDLOCAL & goto :eof


:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
