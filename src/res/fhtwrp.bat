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

TITLE BBK S6一键刷入TWRP QQ@huang1057 官网：https://ghteam.pages.dev
mode con cols=71

::启动准备和检查. 如需跳过命令行工具检查以加快启动速度, 请加入skiptoolchk参数
call framework startpre
::call framework startpre skiptoolchk

TITLE S6一键刷入TWRP 作者:QQ@huang1057///完全免费，严禁倒卖
CLS
goto MENU

set "currentDir=%~dp0"
:MENU
CLS
ECHO.
ECHO.=========================================================
ECHO.=======================BBK S6一键刷入TWRP================
ECHO.=========================================================
ECHO.作者：huang1057----GH工作室
ECHO.=======================官网：https：//ghteam.pages.dev====
ECHO.=========================================================
ECHO.
ECHO.永久免费，严禁倒卖！！！
ECHO.TWRP来自EEBBK BOOM
ECHO.
ECHO.==========================================================
ECHO.
ECHO.开始刷写TWRP
ECHO.检查设备连接：9008
ECHO.请将设备进入9008模式
ECHO.
call chkdev qcedl rechk 2
ECHO.发送引导
call write qcedlsendfh auto %currentDir%s6superroot\firehose.elf auto
ECHO.正在刷写TWRP
call write qcedl recovery %currentDir%s6superroot\recovery.img auto
ECHO.刷写完成，重启
call reboot qcedl recovery
ECHO.
ECHO.=============================================================
ECHO.--------------------完成！！！--------------------------------
ECHO.=============================================================