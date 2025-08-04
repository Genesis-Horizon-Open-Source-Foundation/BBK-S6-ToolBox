::修改: n

::call sel file   [s m] %framework_workspace% [img][bin]...(可选)
::         folder [s m] %framework_workspace%


@ECHO OFF
set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
goto SEL


:SEL
SETLOCAL
set logger=sel.bat
::接收变量
set target=%args1%& set quantity=%args2%& set startfolder=%args3%& set filter=%args4%
call log %logger% I 接收变量:target:%target%.quantity:%quantity%.startfolder:%startfolder%.filter:%filter%
:SEL-1
call log %logger% I 打开选择器
filedialog.exe -t %target% -q %quantity% -o %tmpdir%\sel.txt -s %startfolder% -f %filter%[*] 1>%tmpdir%\output.txt 2>&1 || type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}未选择任何文件. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 未选择任何文件&& pause>nul && ECHO.重试... && goto SEL-1
type %tmpdir%\output.txt>>%logfile%
find "[Warn]Special_character_found" "%tmpdir%\output.txt" 1>nul 2>nul && ECHOC {%c_e%}选择的路径或文件名中不能含有特殊字符, 例如空格, 英文括号, 英文逗号等. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 选择的路径或文件名中含有特殊字符&& pause>nul && ECHO.重试... && goto SEL-1
for /f "tokens=2 delims=[]" %%a in ('type %tmpdir%\output.txt ^| find "[Number]"') do set selectednum=%%a
goto SEL-%target%-%quantity%


:SEL-FILE-S
for /f "tokens=1 delims= " %%a in ('type %tmpdir%\sel.txt ^| find ":"') do set sel__file_path=%%a
for %%a in ("%sel__file_path%") do set sel__file_fullname=%%~nxa
for %%a in ("%sel__file_path%") do set sel__file_name=%%~na
for %%a in ("%sel__file_path%") do set var=%%~xa
if not "%var%"=="" (set sel__file_ext=%var:~1,999%) else (set sel__file_ext=)
for %%a in ("%sel__file_path%") do set var=%%~dpa
set sel__file_folder=%var:~0,-1%
ECHOC {%c_i%}已选择文件: {%c_we%}%sel__file_path%{%c_i%}{\n}& call log %logger% I 已选择文件:%sel__file_path%.完整文件名:%sel__file_fullname%.文件名:%sel__file_name%.扩展名:%sel__file_ext%.所在文件夹路径:%sel__file_folder%
ENDLOCAL & set sel__file_path=%sel__file_path%& set sel__file_fullname=%sel__file_fullname%& set sel__file_name=%sel__file_name%& set sel__file_ext=%sel__file_ext%& set sel__file_folder=%sel__file_folder%
goto :eof

:SEL-FOLDER-S
for /f "tokens=1 delims= " %%a in ('type %tmpdir%\sel.txt ^| find ":"') do set sel__folder_path=%%a
for %%a in ("%sel__folder_path%") do set sel__folder_name=%%~nxa
ECHOC {%c_i%}已选择文件夹: {%c_we%}%sel__folder_path%{%c_i%}{\n}& call log %logger% I 已选择文件夹:%sel__folder_path%.文件夹名:%sel__folder_name%
ENDLOCAL & set sel__folder_path=%sel__folder_path%& set sel__folder_name=%sel__folder_name%
goto :eof

:SEL-FILE-M
for /f "tokens=1 delims= " %%a in ('type %tmpdir%\sel.txt ^| find ":"') do set sel__files=%%a
::获取第一个文件所在文件夹(任何一个文件所在文件夹就一定是这批文件所在文件夹)
for /f "tokens=1 delims=/" %%a in ('echo.%sel__files%') do set var=%%a
for %%a in ("%var%") do set var=%%~dpa
set sel__files_folder=%var:~0,-1%
ECHOC {%c_i%}已选择文件(多选模式): {%c_we%}%sel__files%{%c_i%}{\n}& call log %logger% I 已多选文件:%sel__files%.所在文件夹路径:%sel__files_folder%.文件数目:%sel__files_num%
ENDLOCAL & set sel__files=%sel__files%& set sel__files_folder=%sel__files_folder%& set sel__files_num=%selectednum%
goto :eof

:SEL-FOLDER-M
for /f "tokens=1 delims= " %%a in ('type %tmpdir%\sel.txt ^| find ":"') do set sel__folders=%%a
ECHOC {%c_i%}已选择文件夹(多选模式): {%c_we%}%sel__folders%{%c_i%}{\n}& call log %logger% I 已多选文件夹:%sel__folders%.文件夹数目:%sel__folders_num%
ENDLOCAL & set sel__folders=%sel__folders%& set sel__folders_num=%selectednum%
goto :eof



:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
