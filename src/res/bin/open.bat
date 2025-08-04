::修改: n

::call open [common folder txt pic] 目标路径

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
SETLOCAL
set logger=open.bat
if "%args1%"=="common" start %args2%
if "%args1%"=="folder" (
    if not exist %args2% ECHOC {%c_e%}找不到%args2%, 无法打开. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% E 找不到%args2%& pause>nul & ECHO.继续... & goto DONE
    start "" "%args2%")
if "%args1%"=="txt" (
    if not exist %args2% ECHOC {%c_e%}找不到%args2%, 无法打开. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% E 找不到%args2%& pause>nul & ECHO.继续... & goto DONE
    start tool\Win\Notepad3\Notepad3.exe %args2%)
if "%args1%"=="pic" (
    if not exist %args2% ECHOC {%c_e%}找不到%args2%, 无法打开. {%c_h%}按任意键继续...{%c_i%}{\n}& call log %logger% E 找不到%args2%& pause>nul & ECHO.继续... & goto DONE
    for %%i in ("%args2%") do start tool\Win\Vieas\Vieas.exe /v %%~dpnxi)
goto DONE
:DONE
ENDLOCAL
goto :eof


:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
