::修改: n

::call calc p       输出变量名  [nodec nodec-intp1 dec-保留小数位数]  数字1   数字2
::          s       输出变量名  [nodec nodec-intp1 dec-保留小数位数]  数字1   数字2
::          m       输出变量名  [nodec nodec-intp1 dec-保留小数位数]  数字1   数字2
::          d       输出变量名  [nodec nodec-intp1 dec-保留小数位数]  数字1   数字2
::          b2sec   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  b       扇区大小
::          sec2b   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  扇区数目 扇区大小
::          b2kb    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  b
::          kb2b    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  kb
::          b2mb    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  b
::          mb2b    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  mb
::          b2gb    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  b
::          gb2b    输出变量名  [nodec nodec-intp1 dec-保留小数位数]  gb
::          sec2kb  输出变量名  [nodec nodec-intp1 dec-保留小数位数]  扇区数目 扇区大小
::          kb2sec  输出变量名  [nodec nodec-intp1 dec-保留小数位数]  kb      扇区大小
::          kb2mb   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  kb
::          mb2kb   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  mb
::          kb2gb   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  kb
::          gb2kb   输出变量名  [nodec nodec-intp1 dec-保留小数位数]  gb

::          numcomp 数字1       数字2


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9

SETLOCAL
set logger=calc.bat-%args1%
goto %args1%




:NUMCOMP
set num1=%args2%& set num2=%args3%
set result=
for /f "tokens=1 delims=#" %%a in ('numcomp.exe %num1% %num2%') do set result=%%a
if not "%result%"=="greater" (if not "%result%"=="less" (if not "%result%"=="equal" goto NUMCOMP-FAILED))
call log %logger% I 数字1:%num1%.数字2:%num2%.比较结果:%result%
ENDLOCAL & set calc__numcomp__result=%result%
goto :eof
:NUMCOMP-FAILED
ECHOC {%c_e%}比较大小失败:数字1:%num1%.数字2:%num2%.比较结果:%result%{%c_i%}{\n}& call log %logger% F 比较大小失败:数字1:%num1%.数字2:%num2%.比较结果:%result%
goto FATAL


:B2GB
call :calcmode-argsprocess
set b=%args4%
for /f %%a in ('calc.exe %b% d 1073741824 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:b:%b%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:GB2B
call :calcmode-argsprocess
set gb=%args4%
for /f %%a in ('calc.exe %gb% m 1073741824 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:gb:%gb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:B2MB
call :calcmode-argsprocess
set b=%args4%
for /f %%a in ('calc.exe %b% d 1048576 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:b:%b%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:MB2B
call :calcmode-argsprocess
set mb=%args4%
for /f %%a in ('calc.exe %mb% m 1048576 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:mb:%mb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:SEC2B
call :calcmode-argsprocess
set sec=%args4%& set secsize=%args5%
for /f %%a in ('calc.exe %sec% m %secsize% %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:sec:%sec%.secsize:%secsize%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:B2SEC
call :calcmode-argsprocess
set b=%args4%& set secsize=%args5%
for /f %%a in ('calc.exe %b% d %secsize% %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:b:%b%.secsize:%secsize%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:SEC2KB
call :calcmode-argsprocess
set sec=%args4%& set secsize=%args5%
for /f %%a in ('calc.exe %sec% m %secsize% 12') do set var=%%a
for /f %%a in ('calc.exe %var% d 1024 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:sec:%sec%.secsize:%secsize%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:KB2SEC
call :calcmode-argsprocess
set kb=%args4%& set secsize=%args5%
for /f %%a in ('calc.exe %kb% m 1024 12') do set var=%%a
for /f %%a in ('calc.exe %var% d %secsize% %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:kb:%kb%.secsize:%secsize%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:KB2MB
call :calcmode-argsprocess
set kb=%args4%
for /f %%a in ('calc.exe %kb% d 1024 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:kb:%kb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:MB2KB
call :calcmode-argsprocess
set mb=%args4%
for /f %%a in ('calc.exe %mb% m 1024 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:mb:%mb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:KB2GB
call :calcmode-argsprocess
set kb=%args4%
for /f %%a in ('calc.exe %kb% d 1048576 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:kb:%kb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:GB2KB
call :calcmode-argsprocess
set gb=%args4%
for /f %%a in ('calc.exe %gb% m 1048576 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:gb:%gb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:B2KB
call :calcmode-argsprocess
set b=%args4%
for /f %%a in ('calc.exe %b% d 1024 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:b:%b%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:KB2B
call :calcmode-argsprocess
set kb=%args4%
for /f %%a in ('calc.exe %kb% m 1024 %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入:kb:%kb%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:P
set func=p& goto PSMD
:S
set func=s& goto PSMD
:M
set func=m& goto PSMD
:D
set func=d& goto PSMD
:PSMD
call :calcmode-argsprocess
set input1=%args4%& set input2=%args5%
for /f %%a in ('calc.exe %input1% %func% %input2% %decnum%') do set result=%%a
if "%decmode%"=="nodec-intp1" call :calcmode-nodec-intp1
call log %logger% I 输入1:%input1%.计算方法:%func%.输入2:%input2%.小数处理方法:%decmode%.结果:%output%:%result%
ENDLOCAL & set %output%=%result%
goto :eof

:calcmode-argsprocess
set output=%args2%& set decmode=%args3%
if "%decmode%"=="nodec" set decnum=0
if "%decmode%"=="nodec-intp1" set decnum=13
if "%decmode%"=="dec" set decnum=2
if "%decmode:~0,4%"=="dec-" set decnum=%decmode:~4,999%
goto :eof

:calcmode-nodec-intp1
for /f "tokens=1,2 delims=. " %%a in ('echo.%result%') do set args1=%%a& set args2=%%b
if "%args2%"=="0000000000000" (set result=%args1%) else (for /f %%a in ('calc.exe %args1% p 1 0') do set result=%%a)
goto :eof






:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)

