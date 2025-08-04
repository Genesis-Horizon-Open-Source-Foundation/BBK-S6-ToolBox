@ECHO OFF
chcp 936>nul
cd /d %~dp0
set "currentDir=%~dp0"
if exist bin (cd bin) else (ECHO.找不到bin. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL)

if not exist tool\Win\gap.exe ECHO.找不到gap.exe. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL
tool\Win\gap.exe %0 || EXIT

if exist conf\fixed.bat (call conf\fixed) else (ECHO.找不到conf\fixed.bat. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL)
if exist conf\user.bat call conf\user

::加载主题,请勿改动
if "%framework_theme%"=="" set framework_theme=default
call framework theme %framework_theme%
COLOR %c_i%

TITLE BBK S6一键ROOT QQ@huang1057 官网：https://ghteam.pages.dev
mode con cols=71

::启动准备和检查. 如需跳过命令行工具检查以加快启动速度, 请加入skiptoolchk参数
call framework startpre
::call framework startpre skiptoolchk

TITLE S6一键ROOT 作者:QQ@huang1057///完全免费，严禁倒卖
CLS
goto MENU

set "currentDir=%~dp0"

:MENU
ECHO.===============================================================
ECHO.=======================BBK S6一键ROOT===========================
ECHO.===============================================================
ECHO.作者：huang1057----GH工作室
ECHO.GH工作室官网：https://ghteam.pages.dev
ECHO.===============================================================
ECHO.
ECHO.========================开始Root================================
ECHO. 
call chkdev qcedl rechk 3
ECHO.发送引导
call write qcedlsendfh auto %currentDir%s6superroot\firehose.elf auto
ECHO.修补boot分区
call read qcedl boot %currentDir%s6superroot\boot.img noprompt auto
ECHO.正在修补
call imgkit magiskpatch %currentDir%s6superroot\boot.img %currentDir%s6superroot\boot_out.img %currentDir%s6superroot\magisk.zip noprompt
ECHO.修补完成！正在刷入
call write qcedl boot %currentDir%s6superroot\boot_out.img auto
ECHO.ROOT成功，重启！！！
call reboot qcedl system
ECHO.请前往桌面点击“magisk”应用进行后续操作
ECHO.下载完整版magisk
ECHO.===========================================================
ECHO.------------------完成！！！-------------------------------
ECHO.=========================================================== 
echo.
echo 按任意键退出...
pause >nul
exit /b 0