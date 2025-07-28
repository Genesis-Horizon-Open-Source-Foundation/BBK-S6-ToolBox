::修改: n

::call dl direct 直链               完整保存路径(包括文件名) [retry once] [notice noprompt] 检查字符串(可选)
::        lzlink 蓝奏分享链接(-****) 完整保存路径(包括文件名) [retry once] [notice noprompt] 检查字符串(可选)

@ECHO OFF

set args1=%1& set args2=%2& set args3=%3& set args4=%4& set args5=%5& set args6=%6& set args7=%7& set args8=%8& set args9=%9
SETLOCAL
set logger=dl.bat
set dlmode=%args1%& set link_orig=%args2%& set filepath=%args3%& set dltimes=%args4%& set fileexistfunc=%args5%& set chkfield=%args6%
call log %logger% I 接收变量:dlmode:%dlmode%.link_orig:%link_orig%.filepath:%filepath%.dltimes:%dltimes%.fileexistfunc:%fileexistfunc%.chkfield:%chkfield%
goto %dlmode%




:DIRECT
if not "%fileexistfunc%"=="noprompt" (
    if exist %filepath% (
        ECHOC {%c_w%}%filepath%已存在.继续将覆盖此文件.{%c_h%}按任意键继续...{%c_i%}{\n}&& call log %logger% W %filepath%已存在.继续将覆盖此文件&& pause>nul && ECHO.继续...
        del /Q %filepath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%filepath%失败.{%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 删除%filepath%失败&& pause>nul && ECHO.重试... && goto DIRECT))
set link_direct=%link_orig%
call :startdl
if "%result%"=="y" goto FINISH
::下载失败
if "%dltimes%"=="once" (goto FINISH) else (ECHO.自动重试... & goto DIRECT)


:LZLINK
for /f "tokens=2 delims=[]" %%a in ('echo.%link_orig%') do (if not "%%a"=="" goto LZLINK-STV)
goto LZLINK-SINGLE

:LZLINK-SINGLE
if not "%fileexistfunc%"=="noprompt" (
    if exist %filepath% (
        ECHOC {%c_w%}%filepath%已存在.继续将覆盖此文件.{%c_h%}按任意键继续...{%c_i%}{\n}&& call log %logger% W %filepath%已存在.继续将覆盖此文件&& pause>nul && ECHO.继续...
        del /Q %filepath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%filepath%失败.{%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 删除%filepath%失败&& pause>nul && ECHO.重试... && goto LZLINK-SINGLE))
for /f "tokens=1 delims=[]" %%a in ('echo.%link_orig%') do set link_lz=%%a
echo.%link_lz% | find "-" 1>nul 2>nul
if not "%errorlevel%"=="0" (call :getlzdirectlink-nopswd) else (call :getlzdirectlink-pswd)
call :startdl
if "%result%"=="y" goto FINISH
::下载失败
if "%dltimes%"=="once" (goto FINISH) else (ECHO.自动重试... & goto LZLINK-SINGLE)

:LZLINK-STV
if not "%fileexistfunc%"=="noprompt" (
    if exist %filepath%.??? (
        ECHOC {%c_w%}%filepath%.xxx已存在.继续将覆盖此^(类^)文件.{%c_h%}按任意键继续...{%c_i%}{\n}&& call log %logger% W %filepath%.xxx已存在.继续将覆盖此^(类^)文件&& pause>nul && ECHO.继续...
        del /Q %filepath%.??? 1>>%logfile% 2>&1 || ECHOC {%c_e%}删除%filepath%.xxx失败.{%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E 删除%filepath%.xxx失败&& pause>nul && ECHO.重试... && goto LZLINK-STV))
set filepath_orig=%filepath%
set num=1
:LZLINK-STV-1
set link_lz=
for /f "tokens=%num% delims=[]" %%a in ('echo.%link_orig%') do set link_lz=%%a
if "%link_lz%"=="" goto FINISH
echo.%link_lz% | find "-" 1>nul 2>nul
if not "%errorlevel%"=="0" (call :getlzdirectlink-nopswd) else (call :getlzdirectlink-pswd)
if not "%num:~0,1%"=="" set filepath=%filepath_orig%.00%num%
if not "%num:~1,1%"=="" set filepath=%filepath_orig%.0%num%
if not "%num:~2,1%"=="" set filepath=%filepath_orig%.%num%
call :startdl
if "%result%"=="y" set /a num+=1& goto LZLINK-STV-1
::下载失败
if "%dltimes%"=="once" (goto FINISH) else (ECHO.自动重试... & goto LZLINK-STV-1)


:FINISH
call log %logger% I 下载结果为%result%.退出下载模块
ENDLOCAL & set dl__result=%result%
goto :eof


:getlzdirectlink-nopswd
::获取原始链接的两个部分
echo.%link_lz% | find "https" 1>nul 2>nul
if "%errorlevel%"=="0" (set var=2) else (set var=1)
for /f "tokens=%var% delims=/ " %%a in ('echo.%link_lz%') do set link_lz_value1=%%a
echo.%link_lz% | find "/tp/" 1>nul 2>nul
if "%errorlevel%"=="0" (set /a var+=2) else (set /a var+=1)
for /f "tokens=%var% delims=/ " %%a in ('echo.%link_lz%') do set link_lz_value2=%%a
::解析原始链接, 获得tp链接
call log %logger% I 即将解析原始链接:https://%link_lz_value1%/%link_lz_value2%
curl.exe -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" https://%link_lz_value1%/%link_lz_value2% 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析原始链接https://%link_lz_value1%/%link_lz_value2%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析原始链接https://%link_lz_value1%/%link_lz_value2%失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-nopswd
busybox.exe sed -i "s/\"/#/g" %tmpdir%\output.txt
set link_lz_tp_part2=
for /f "tokens=4 delims=#" %%a in ('type %tmpdir%\output.txt ^| find "<div class=#mh#><a href=#/tp/"') do set link_lz_tp_part2=%%a
if "%link_lz_tp_part2%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取tp链接第2部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取tp链接第2部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-nopswd
set link_lz_tp=https://%link_lz_value1%%link_lz_tp_part2%
::解析tp链接, 获得developer链接
call log %logger% I 即将解析tp链接:%link_lz_tp%
curl.exe -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" %link_lz_tp% 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析tp链接失败.{%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析tp链接失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-nopswd
set link_lz_developer_part1=
for /f "tokens=4 delims='; " %%a in ('type %tmpdir%\output.txt ^| find "var vkjxld "') do set link_lz_developer_part1=%%a
if "%link_lz_developer_part1%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取developer链接第1部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取developer链接第1部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-nopswd
set link_lz_developer_part2=
for /f "tokens=4 delims='; " %%a in ('type %tmpdir%\output.txt ^| find "var hyggid "') do set link_lz_developer_part2=%%a
if "%link_lz_developer_part2%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取developer链接第2部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取developer链接第2部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-nopswd
set link_lz_developer=%link_lz_developer_part1%%link_lz_developer_part2%
::解析developer链接, 获得直链
call log %logger% I 即将解析developer链接:"%link_lz_developer%"
curl.exe -i -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" %link_lz_developer% --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --header "Accept-Encoding: gzip, deflate" --header "Accept-Language: zh-CN,zh;q=0.9" --header "Cache-Control: no-cache" --header "Connection: keep-alive" --header "Pragma: no-cache" --header "Upgrade-Insecure-Requests: 1" 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析developer链接失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析developer链接失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-nopswd
set link_direct=
for /f "tokens=2 delims= " %%a in ('type %tmpdir%\output.txt ^| find "Location: "') do set link_direct=%%a
if "%link_direct%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取直链失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取直链失败& pause>nul & ECHO.重试... & goto getlzdirectlink-nopswd
set link_direct="%link_direct%"
call log %logger% I 获得直链:%link_direct%
goto :eof

:getlzdirectlink-pswd
::获取原始链接的两个部分
for /f "tokens=1,2 delims=-" %%a in ('echo.%link_lz%') do (set link_lz_withoutpswd=%%a& set link_lz_pswd=%%b)
echo.%link_lz_withoutpswd% | find "https" 1>nul 2>nul
if "%errorlevel%"=="0" (set var=2) else (set var=1)
for /f "tokens=%var% delims=/ " %%a in ('echo.%link_lz_withoutpswd%') do set link_lz_value1=%%a
echo.%link_lz_withoutpswd% | find "/tp/" 1>nul 2>nul
if "%errorlevel%"=="0" (set /a var+=2) else (set /a var+=1)
for /f "tokens=%var% delims=/ " %%a in ('echo.%link_lz_withoutpswd%') do set link_lz_value2=%%a
::解析原始链接, 获得tp链接
call log %logger% I 即将解析原始链接:https://%link_lz_value1%/%link_lz_value2%.密码:%link_lz_pswd%
curl.exe -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" https://%link_lz_value1%/%link_lz_value2% 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析原始链接https://%link_lz_value1%/%link_lz_value2%密码%link_lz_pswd%失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析原始链接https://%link_lz_value1%/%link_lz_value2%失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-pswd
busybox.exe sed -i "s/\"/#/g" %tmpdir%\output.txt
set link_lz_tp_part2=
for /f "tokens=4 delims=#" %%a in ('type %tmpdir%\output.txt ^| find "<div class=#mh#><a href=#/tp/"') do set link_lz_tp_part2=%%a
if "%link_lz_tp_part2%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取tp链接第2部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取tp链接第2部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
set link_lz_tp=https://%link_lz_value1%%link_lz_tp_part2%
::解析tp链接, 获得postsign
call log %logger% I 即将解析tp链接:%link_lz_tp%
curl.exe -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" %link_lz_tp% 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析tp链接失败.{%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析tp链接失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-pswd
set link_lz_postsign=
for /f "tokens=4 delims=' " %%a in ('type %tmpdir%\output.txt ^| find "var vidksek"') do set link_lz_postsign=%%a
if "%link_lz_postsign%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取postsign失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取postsign失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
::使用postsign解析, 获得developer链接
call log %logger% I 即将使用postsign:%link_lz_postsign%解析
curl.exe -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" -e "https://%link_lz_value1%" https://%link_lz_value1%/ajaxm.php --data-raw "action=downprocess&sign=%link_lz_postsign%&p=%link_lz_pswd%" 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl使用postsign解析失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl使用postsign解析失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-pswd
busybox.exe sed -i "s/\"/ /g;s/\\//g" %tmpdir%\output.txt
set link_lz_developer_part1=& set link_lz_developer_part2=
for /f "tokens=6,10 delims= " %%a in ('type %tmpdir%\output.txt ^| find "http"') do (set link_lz_developer_part1=%%a& set link_lz_developer_part2=%%b)
if "%link_lz_developer_part1%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取developer链接第1部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取developer链接第1部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
if "%link_lz_developer_part2%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取developer链接第2部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取developer链接第2部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
if "%link_lz_developer_part2%"=="inf" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取developer链接第2部分失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取developer链接第2部分失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
set link_lz_developer=%link_lz_developer_part1%/file/%link_lz_developer_part2%
::解析developer链接, 获得直链
call log %logger% I 即将解析developer链接:"%link_lz_developer%"
curl.exe -i -k -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25" %link_lz_developer% --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --header "Accept-Encoding: gzip, deflate" --header "Accept-Language: zh-CN,zh;q=0.9" --header "Cache-Control: no-cache" --header "Connection: keep-alive" --header "Pragma: no-cache" --header "Upgrade-Insecure-Requests: 1" 1>%tmpdir%\output.txt 2>%tmpdir%\output2.txt || type %tmpdir%\output2.txt>>%logfile%&& type %tmpdir%\output.txt>>%logfile%&& ECHOC {%c_e%}curl解析developer链接失败. {%c_h%}按任意键重试...{%c_i%}{\n}&& call log %logger% E curl解析developer链接失败&& pause>nul && ECHO.重试... && goto getlzdirectlink-pswd
set link_direct=
for /f "tokens=2 delims= " %%a in ('type %tmpdir%\output.txt ^| find "Location: "') do set link_direct=%%a
if "%link_direct%"=="" type %tmpdir%\output.txt>>%logfile%& ECHOC {%c_e%}获取直链失败. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 获取直链失败& pause>nul & ECHO.重试... & goto getlzdirectlink-pswd
set link_direct="%link_direct%"
call log %logger% I 获得直链:%link_direct%
goto :eof


:startdl
call log %logger% I 即将下载%link_direct%到%tmpdir%\dl\bffdl.tmp
if exist %tmpdir%\dl rd /s /q %tmpdir%\dl 1>nul 2>>%logfile% || ECHOC {%c_e%}删除%tmpdir%\dl失败{%c_i%}{\n}&& call log %logger% E 删除%tmpdir%\dl失败
md %tmpdir%\dl 1>nul 2>>%logfile% || ECHOC {%c_e%}创建%tmpdir%\dl失败{%c_i%}{\n}&& call log %logger% E 创建%tmpdir%\dl失败
cd %tmpdir%\dl
aria2c.exe --max-concurrent-downloads=16 --max-connection-per-server=16 --split=16 --file-allocation=none --out=bffdl.tmp %link_direct% 1>>%logfile% 2>&1 || cd %framework_workspace%&& ECHOC {%c_e%}下载失败{%c_i%}{\n}&& call log %logger% E 本次下载失败&& set result=n&& goto :eof
cd %framework_workspace%
if not "%chkfield%"=="" find "%chkfield%" "%tmpdir%\dl\bffdl.tmp" 1>nul 2>nul || ECHOC {%c_e%}检验失败,找不到指定的字符,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.找不到指定的字符:%chkfield%.下载失败&& set result=n&& goto :eof
for /f "tokens=3 delims= " %%a in ('dir %tmpdir%\dl /-C /-N /A:-D ^| find "bffdl"') do set var=%%a
if %var% LEQ 10240 (
    find "code" "%tmpdir%\dl\bffdl.tmp" | find ": 400," 1>nul 2>nul && ECHOC {%c_e%}检验失败,发现报错,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.发现报错.下载失败&& set result=n&& goto :eof
    find "code" "%tmpdir%\dl\bffdl.tmp" | find ": 201," 1>nul 2>nul && ECHOC {%c_e%}检验失败,发现报错,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.发现报错.下载失败&& set result=n&& goto :eof
    find "path not found" "%tmpdir%\dl\bffdl.tmp" | find ":500," 1>nul 2>nul && ECHOC {%c_e%}检验失败,找不到云端路径,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.找不到云端路径.下载失败&& set result=n&& goto :eof
    find "could not be found" "%tmpdir%\dl\bffdl.tmp" | find ":500," 1>nul 2>nul && ECHOC {%c_e%}检验失败,发现报错,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.发现报错.下载失败&& set result=n&& goto :eof
    find "failed to get file" "%tmpdir%\dl\bffdl.tmp" | find ":500," 1>nul 2>nul && ECHOC {%c_e%}检验失败,找不到云端文件,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.找不到云端文件.下载失败&& set result=n&& goto :eof
    find "Loading storage, please wait" "%tmpdir%\dl\bffdl.tmp" | find ":500," 1>nul 2>nul && ECHOC {%c_e%}检验失败,云存储还未加载完毕,下载失败{%c_i%}{\n}&& call log %logger% E 检验失败.云存储还未加载完毕.下载失败&& set result=n&& goto :eof)
move /Y %tmpdir%\dl\bffdl.tmp %filepath% 1>>%logfile% 2>&1 || ECHOC {%c_e%}移动失败{%c_i%}{\n}&& call log %logger% E 移动失败&& set result=n&& goto :eof
set result=y& call log %logger% I 本次下载成功
goto :eof






:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
