::修改: n

::call input choice [1][2][3][4][5]#[A][B](可选)
::           

@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto %args1%


:CHOICE
SETLOCAL
set logger=input.bat-choice
set options=%args2%
:CHOICE-1
::检查和获取默认选项
set choice_default=
echo.%options% | find "#[" 1>nul 2>nul || goto CHOICE-2
for /f "tokens=2 delims=#" %%a in ('echo.BFF%options%') do set var=%%a
for /f "tokens=1 delims=[]" %%a in ('echo.%var%') do set choice_default=%%a
:CHOICE-2
::用户输入
if "%choice_default%"=="" (ECHOC {%c_h%}输入序号按Enter继续: {%c_i%}) else (ECHOC {%c_h%}输入序号按Enter继续^(默认:%choice_default%^): {%c_i%})
call strtofile.exe %tmpdir%\choice.txt
busybox.exe sed -i "s/a/A/g;s/b/B/g;s/c/C/g;s/d/D/g;s/e/E/g;s/f/F/g;s/g/G/g;s/h/H/g;s/i/I/g;s/j/J/g;s/k/K/g;s/l/L/g;s/m/M/g;s/n/N/g;s/o/O/g;s/p/P/g;s/q/Q/g;s/r/R/g;s/s/S/g;s/t/T/g;s/u/U/g;s/v/V/g;s/w/W/g;s/x/X/g;s/y/Y/g;s/z/Z/g" %tmpdir%\choice.txt
::读取用户输入
set choice=
for /f "tokens=1 delims=#" %%a in (%tmpdir%\choice.txt) do set choice=%%a
::检查用户输入
find """" "%tmpdir%\choice.txt" 1>nul 2>nul && ECHOC {%c_e%}输入的内容中有特殊符号. 请重新输入.{%c_i%}{\n}&& goto CHOICE-1
find " " "%tmpdir%\choice.txt" 1>nul 2>nul && ECHOC {%c_e%}输入的内容中有特殊符号. 请重新输入.{%c_i%}{\n}&& goto CHOICE-1
findstr "~ ! @ # %% ^ & * ( ) + = [ ] | : ; ' < > ," "%tmpdir%\choice.txt" 1>nul 2>nul && ECHOC {%c_e%}输入的内容中有特殊符号. 请重新输入.{%c_i%}{\n}&& goto CHOICE-1
if "%choice%"=="" set choice=%choice_default%
if not "%options%"=="" echo.%options% | find "[%choice%]" 1>nul 2>nul || ECHOC {%c_e%}输入错误, 输入的选项不在%options%中. 请重新输入.{%c_i%}{\n}&& goto CHOICE-1
::完成选择
call log %logger% I 选择%choice%
ENDLOCAL & set input__choice=%choice%& set choice=%choice%
goto :eof



















:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)


