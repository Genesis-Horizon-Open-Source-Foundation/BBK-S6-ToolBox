::这是一个主脚本示例,请按照此示例中的启动过程完成脚本的启动.

::常规准备,请勿改动
@ECHO OFF
chcp 936>nul
cd /d %~dp0
if exist bin (cd bin) else (ECHO.找不到bin. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL)

::检查和获取管理员权限,若不涉及需要管理员权限的程序可以去除
if not exist tool\Win\gap.exe ECHO.找不到gap.exe. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL
tool\Win\gap.exe %0 || EXIT

::加载配置,如果有自定义的配置文件也可以加在下面
if exist conf\fixed.bat (call conf\fixed) else (ECHO.找不到conf\fixed.bat. 请检查工具是否完全解压, 脚本位置是否正确. & goto FATAL)
if exist conf\user.bat call conf\user

::加载主题,请勿改动
if "%framework_theme%"=="" set framework_theme=default
call framework theme %framework_theme%
COLOR %c_i%

::自定义窗口大小,可以按照需要改动
TITLE 工具启动中...
mode con cols=71

::启动准备和检查. 如需跳过命令行工具检查以加快启动速度, 请加入skiptoolchk参数
call framework startpre
::call framework startpre skiptoolchk

::完成启动.请在下面编写你的脚本
TITLE 工具示例 框架版本:%framework_ver% 作者:酷安@某贼
CLS
goto MENU



:MENU
call log example.bat-menu I 进入主菜单
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.主菜单
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.此脚本用于演示和测试各模块功能
ECHO.
ECHO.1.chkdev.bat 检查设备连接
ECHO.2.dl.bat 下载模块
ECHO.3.imgkit.bat 分区镜像处理
ECHO.4.info.bat 读取设备信息
ECHO.5.read.bat 读出
ECHO.6.reboot.bat 重启
ECHO.7.write.bat 写入
ECHO.8.clean.bat 清除
ECHO.9.scrcpy.bat 投屏
ECHO.10.更换主题
ECHO.11.槽位功能
ECHO.12.开关日志
ECHO.13.partable.bat 分区表
ECHO.14.实时日志监控
ECHO.15.sel.bat 选择文件(夹)
ECHO.16.random.bat 生成随机数
ECHO.17.input.bat 选择
ECHO.18.calc.bat 计算模块
ECHO.A.关于BFF
ECHO.
call input choice [1][2][3][4][5][6][7][8][9][10][11][12][13][14][15][16][17][18]#[A]
if "%choice%"=="1" goto CHKDEV
if "%choice%"=="2" goto DL
if "%choice%"=="3" goto IMGKIT
if "%choice%"=="4" goto INFO
if "%choice%"=="5" goto READ
if "%choice%"=="6" goto REBOOT
if "%choice%"=="7" goto WRITE
if "%choice%"=="8" goto CLEAN
if "%choice%"=="9" goto SCRCPY
if "%choice%"=="10" goto THEME
if "%choice%"=="11" goto SLOT
if "%choice%"=="12" goto LOG
if "%choice%"=="13" goto PARTABLE
if "%choice%"=="14" goto LOGVIEWER
if "%choice%"=="15" goto SEL
if "%choice%"=="16" goto RANDOM
if "%choice%"=="17" goto INPUT
if "%choice%"=="18" goto CALC
if "%choice%"=="A" call open common https://gitee.com/mouzei/bff & goto MENU




:CALC
SETLOCAL
set logger=example.bat-calc
call log %logger% I 进入功能CALC
:CALC-1
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.calc.bat 计算
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.2147483647+2147483647 不保留小数 正确值:4294967294
call calc p calc_result nodec 2147483647 2147483647
ECHO.[%calc_result%]
ECHO.
ECHO.2147483648-1 保留3位小数 正确值:2147483647.000
call calc s calc_result dec-3 2147483648 1
ECHO.[%calc_result%]
ECHO.
ECHO.1073741824*10 不保留小数且小数不为0进1 正确值:10737418240
call calc m calc_result nodec-intp1 1073741824 10
ECHO.[%calc_result%]
ECHO.
ECHO.5/3 不保留小数且小数不为0进1 正确值:2
call calc d calc_result nodec-intp1 5 3
ECHO.[%calc_result%]
ECHO.
ECHO.5/3 保留2位小数 正确值:1.66
call calc d calc_result dec-2 5 3
ECHO.[%calc_result%]
ECHO.
ECHO.3133461b转扇区 扇区大小512 不保留小数且小数不为0进1 正确值:6121
call calc b2sec calc_result nodec-intp1 3133461 512
ECHO.[%calc_result%]
ECHO.
ECHO.6扇区转b 扇区大小4096 不保留小数 正确值:24576
call calc sec2b calc_result nodec 6 4096
ECHO.[%calc_result%]
ECHO.
ECHO.2047b转kb 不保留小数 正确值:1
call calc b2kb calc_result nodec 2047
ECHO.[%calc_result%]
ECHO.
ECHO.6kb转b 不保留小数 正确值:6144
call calc kb2b calc_result nodec 6
ECHO.[%calc_result%]
ECHO.
ECHO.6b转mb 不保留小数且小数不为0进1 正确值:1
call calc b2mb calc_result nodec-intp1 6
ECHO.[%calc_result%]
ECHO.
ECHO.1b转mb 不保留小数且小数不为0进1 正确值:1
call calc b2mb calc_result nodec-intp1 1
ECHO.[%calc_result%]
ECHO.
ECHO.1mb转b 不保留小数且小数不为0进1 正确值:1048576
call calc mb2b calc_result nodec-intp1 1
ECHO.[%calc_result%]
ECHO.
ECHO.1b转gb 不保留小数且小数不为0进1 正确值:1
call calc b2gb calc_result nodec-intp1 1
ECHO.[%calc_result%]
ECHO.
ECHO.1gb转b 不保留小数且小数不为0进1 正确值:1073741824
call calc gb2b calc_result nodec-intp1 1
ECHO.[%calc_result%]
ECHO.
ECHO.比较00011258999068426240与00000021258999068426240 正确值:less
call calc numcomp 00011258999068426240 00000021258999068426240
ECHO.[%calc__numcomp__result%]
ECHO.
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能CALC& pause>nul & goto MENU


:INPUT
SETLOCAL
set logger=example.bat-input
call log %logger% I 进入功能INPUT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.input.bat 输入
ECHO.=--------------------------------------------------------------------=
:INPUT-1
ECHO.
call input choice
ECHO.[%choice%]
goto INPUT-1


:RANDOM
SETLOCAL
set logger=example.bat-random
call log %logger% I 进入功能RANDOM
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.random.bat 生成随机数
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.在默认字符池(abcdefghijklmnopqrstuvwxyz0123456789)中生成5位随机数.
ECHO.
:RANDOM-1
call random 2 3456
ECHO.结果: [%random__str%]
ECHOC {%c_h%}按任意键重新生成...{%c_i%}{\n}& pause>nul & goto RANDOM-1


:SEL
SETLOCAL
set logger=example.bat-sel
call log %logger% I 进入功能SEL
:SEL-1
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.sel.bat 选择文件(夹)
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.单选文件
ECHO.2.多选文件
ECHO.3.单选文件夹
ECHO.4.多选文件夹
ECHO.
call input choice [1][2][3][4]
if "%choice%"=="1" call sel file s %framework_workspace% [bat]
if "%choice%"=="2" call sel file m %framework_workspace% [bat]
if "%choice%"=="3" call sel folder s %framework_workspace%
if "%choice%"=="4" call sel folder m %framework_workspace%
ECHO.
if "%choice%"=="1" ECHO.完整路径[%sel__file_path%]& ECHO.完整文件名[%sel__file_fullname%]& ECHO.文件名(不包括扩展名)[%sel__file_name%]& ECHO.扩展名[%sel__file_ext%]& ECHO.所在文件夹完整路径[%sel__file_folder%]
if "%choice%"=="2" ECHO.所有文件完整路径(以/分隔)[%sel__files%]& ECHO.所在文件夹完整路径[%sel__files_folder%]& ECHO.文件数目[%sel__files_num%]
if "%choice%"=="3" ECHO.完整路径[%sel__folder_path%]& ECHO.文件夹名[%sel__folder_name%]
if "%choice%"=="4" ECHO.所有文件夹完整路径(以/分隔)[%sel__folders%]& ECHO.文件夹数目[%sel__folders_num%]
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回...{%c_i%}{\n}& pause>nul & goto SEL


:LOGVIEWER
SETLOCAL
set logger=example.bat-logviewer
call log %logger% I 进入功能LOGVIEWER
:LOGVIEWER-1
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.framework.bat 实时日志监控
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.当前日志文件: %logfile%
ECHO.
ECHO.1.开启监控
ECHO.2.关闭监控
ECHO.A.返回主菜单
ECHO.
call input choice [1][2][A]
if "%choice%"=="1" start framework logviewer start %logfile%
if "%choice%"=="2" call framework logviewer end
if "%choice%"=="A" ENDLOCAL & call log %logger% I 完成功能LOGVIEWER& goto MENU
goto LOGVIEWER-1


:CHKDEV
SETLOCAL
set logger=example.bat-chkdev
call log %logger% I 进入功能CHKDEV
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.chkdev.bat 检查设备连接
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.检查设备连接(全部)
ECHO.2.检查设备连接(系统)
ECHO.3.检查设备连接(Recovery)
ECHO.4.检查设备连接(sideload)
ECHO.5.检查设备连接(Fastboot)
ECHO.6.检查设备连接(9008模式)
ECHO.7.检查设备连接(高通基带调试模式)
ECHO.8.检查设备连接(sprdboot)
ECHO.9.检查设备连接(mtkbrom)
ECHO.10.检查设备连接(mtkpreloader)
ECHO.11.检查设备连接(全部) 复查
ECHO.12.检查设备连接(系统) 2秒后复查
call input choice [1][2][3][4][5][6][7][8][9][10][11][12]
if "%choice%"=="1" call chkdev all
if "%choice%"=="2" call chkdev system
if "%choice%"=="3" call chkdev recovery
if "%choice%"=="4" call chkdev sideload
if "%choice%"=="5" call chkdev fastboot
if "%choice%"=="6" call chkdev qcedl
if "%choice%"=="7" call chkdev qcdiag
if "%choice%"=="8" call chkdev sprdboot
if "%choice%"=="9" call chkdev mtkbrom
if "%choice%"=="10" call chkdev mtkpreloader
if "%choice%"=="11" call chkdev all rechk 2
if "%choice%"=="12" call chkdev system rechk 2
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能CHKDEV& pause>nul & goto MENU


:DL
SETLOCAL
set logger=example.bat-dl
call log %logger% I 进入功能DL
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.dl.bat 下载
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.下载直链
ECHO.2.下载蓝奏分享链接
call input choice [1][2]
goto DL-C%choice%
:DL-C1
ECHOC {%c_h%}请输入直链: {%c_i%}& set /p choice=
ECHOC {%c_h%}请选择保存文件夹...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
call dl direct %choice% %sel__folder_path%\dl.test once notice
goto DL-DONE
:DL-C2
ECHOC {%c_h%}请输入蓝奏分享链接: {%c_i%}& set /p choice=
ECHOC {%c_h%}请选择保存文件夹...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
call dl lzlink %choice% %sel__folder_path%\dl.test once notice
goto DL-DONE
:DL-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能DL& pause>nul & goto MENU


:IMGKIT
SETLOCAL
set logger=example.bat-imgkit
call log %logger% I 进入功能IMGKIT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.imgkit.bat 分区镜像处理模块
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.面具修补boot
ECHO.2.为boot注入recovery
call input choice [1][2]
goto IMGKIT-C%choice%
:IMGKIT-C1
ECHOC {%c_h%}请选择boot文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
set bootpath=%sel__file_path%
ECHOC {%c_h%}请选择Magisk(可以是zip或apk)...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [zip][apk]
set zippath=%sel__file_path%
ECHOC {%c_h%}请选择新boot保存位置...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
for /f %%a in ('gettime.exe') do set var=%%a
call imgkit magiskpatch %bootpath% %sel__folder_path%\boot_magiskpatched_%var%.img %zippath%
move /Y %sel__folder_path%\boot_magiskpatched_%var%.img %sel__folder_path%\boot_magiskpatched_%imgkit__magiskpatch__vername%_%imgkit__magiskpatch__ver%_%var%.img 1>>%logfile% 2>&1
goto IMGKIT-DONE
:IMGKIT-C2
ECHOC {%c_h%}请选择boot.img...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
set bootpath=%sel__file_path%
ECHOC {%c_h%}请选择recovery(可以是img或ramdisk.cpio)...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img][cpio]
set recpath=%sel__file_path%
ECHOC {%c_h%}请选择新boot保存位置...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
set outputpath=%sel__folder_path%\boot_new.img
call imgkit recinst %bootpath% %outputpath% %recpath%
goto IMGKIT-DONE
:IMGKIT-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能IMGKIT& pause>nul & goto MENU


:INFO
SETLOCAL
set logger=example.bat-info
call log %logger% I 进入功能INFO
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.info.bat 读取设备信息
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.读取分区信息
ECHO.2.ADB或Fastboot读信息
ECHO.3.读取磁盘信息(如/dev/block/sda或/dev/block/mmcblk0)
ECHO.4.高通9008读信息
call input choice [1][2][3][4]
goto INFO-C%choice%
:INFO-C1
ECHOC {%c_h%}分区名: {%c_i%}& set /p parname=
if "%parname%"=="" goto INFO-C1
ECHOC {%c_h%}请将设备进入系统或Recovery模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}模式错误, 请进入系统或Recovery模式. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto INFO-C1)
call info par %parname% back
if "%info__par__exist%"=="y" (ECHO.%info__par__path%) else (ECHO.分区不存在)
goto INFO-DONE
:INFO-C2
ECHOC {%c_h%}请将设备进入系统,Recovery或Fastboot模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}模式错误, 请进入系统, Recovery或Fastboot模式. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto INFO-C2))
if "%chkdev__mode%"=="system" call info adb
if "%chkdev__mode%"=="recovery" call info adb
if "%chkdev__mode%"=="fastboot" call info fastboot
ECHO.ADB信息: [设备代号:%info__adb__product%] [安卓版本:%info__adb__androidver%] [SDK版本:%info__adb__sdkver%]
ECHO.Fastboot信息: [设备代号:%info__fastboot__product%] [解锁状态:%info__fastboot__unlocked%]
goto INFO-DONE
:INFO-C3
ECHOC {%c_h%}磁盘路径: {%c_i%}& set /p diskpath=
if "%diskpath%"=="" goto INFO-C3
ECHOC {%c_h%}请将设备进入系统或Recovery模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}模式错误, 请进入系统或Recovery模式. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto INFO-C3)
call info disk %diskpath%
ECHO.磁盘类型: [%info__disk__type%]& ECHO.扇区大小: [%info__disk__secsize%]& ECHO.最大分区数: [%info__disk__maxparnum%]
goto INFO-DONE
:INFO-C4
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl rechk 1
ECHO.正在读取信息... & call info qcedl %chkdev__port__qcedl% %fh%
ECHO.存储类型: [%info__qcedl__memtype%]
ECHO.lun总数: [%info__qcedl__lunnum%]
ECHO.扇区大小: [%info__qcedl__secsize%]
goto INFO-DONE
:INFO-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能INFO& pause>nul & goto MENU


:READ
SETLOCAL
set logger=example.bat-read
call log %logger% I 进入功能READ
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.read.bat 读出
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.系统或Recovery读出分区镜像
ECHO.2.高通9008读出分区镜像 (xml模式)
ECHO.3.高通9008读出分区镜像 (单分区模式)
ECHO.4.高通基带调试模式读出QCN
call input choice [1][2][3][4]
goto READ-C%choice%
:READ-C1
ECHOC {%c_h%}请输入要读出的分区名: {%c_i%}& set /p parname=
if "%parname%"=="" goto READ-C1
call log %logger% I 输入分区名:%parname%
ECHOC {%c_h%}请选择img文件保存位置...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHOC {%c_h%}请将设备进入系统或Recovery模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}模式错误, 请进入系统或Recovery模式. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 模式错误:%chkdev__mode%.应进入系统或Recovery模式& pause>nul & ECHO.重试... & goto READ-C1)
ECHO.正在将%parname%读出到%sel__folder_path%(%chkdev__mode%)...& call read %chkdev__mode% %parname% %sel__folder_path%\%parname%.img
goto READ-DONE
:READ-C2
ECHOC {%c_h%}请选择img文件保存目录...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
set searchpath=%sel__folder_path%
ECHOC {%c_h%}请选择rawprogram.xml文件...{%c_i%}{\n}& call sel file m %framework_workspace% [xml]
set xml=%sel__files%
ECHO.是否选择patch.xml文件? & ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择patch.xml文件...{%c_i%}{\n}& call sel file m %framework_workspace% [xml]
if "%choice%"=="1" set xml=%xml%/%sel__files%
set fh=
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl rechk 1
call read qcedlxml %chkdev__port__qcedl% auto %searchpath% %xml% %fh%
goto READ-DONE
:READ-C3
ECHOC {%c_h%}请输入要读出的分区名: {%c_i%}& set /p parname=
if "%parname%"=="" goto READ-C3
call log %logger% I 输入分区名:%parname%
ECHOC {%c_h%}请选择img文件保存目录...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl rechk 1
start framework logviewer start %logfile%
call read qcedl %parname% %sel__folder_path%\%parname%.img notice auto %fh%
call framework logviewer end
goto READ-DONE
:READ-C4
ECHOC {%c_h%}请选择QCN文件保存目录...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHOC {%c_h%}请将设备开机, 开启USB调试并同意Root权限申请...{%c_i%}{\n}& call chkdev system rechk 1
ECHO.开启高通基带调试模式... & call reboot system qcdiag rechk 1
call read qcdiag %chkdev__port__qcdiag% %sel__folder_path%\qcnbak.qcn
goto READ-DONE
:READ-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能READ& pause>nul & goto MENU


:REBOOT
SETLOCAL
set logger=example.bat-reboot
call log %logger% I 进入功能REBOOT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.reboot.bat 重启
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.请选择要进入的模式:
ECHO.1.system
ECHO.2.recovery
ECHO.3.sideload
ECHO.4.fastboot
ECHO.5.fastbootd
ECHO.6.qcedl
ECHO.7.qcdiag
call input choice [1][2][3][4][5][6][7]
if "%choice%"=="1" set target=system
if "%choice%"=="2" set target=recovery
if "%choice%"=="3" set target=sideload
if "%choice%"=="4" set target=fastboot
if "%choice%"=="5" set target=fastbootd
if "%choice%"=="6" set target=qcedl
if "%choice%"=="7" set target=qcdiag
call chkdev all rechk 1
ECHO.进入%target%模式... & call reboot %chkdev__mode% %target% rechk 1
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能REBOOT& pause>nul & goto MENU


:WRITE
SETLOCAL
set logger=example.bat-write
call log %logger% I 进入功能WRITE
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.write.bat 写入
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.刷入分区镜像: 系统,Recovery或Fastboot
ECHO.2.Fastboot临时启动
ECHO.3.高通9008刷入 (xml模式)
ECHO.4.高通9008刷入分区镜像 (单分区模式)
ECHO.5.adb push
ECHO.6.高通基带调试端口写入QCN
ECHO.7.高通9008发送引导
ECHO.
call input choice [1][2][3][4][5][6][7]
goto WRITE-C%choice%
:WRITE-C1
ECHOC {%c_h%}请输入要刷入的分区名: {%c_i%}& set /p parname=
if "%parname%"=="" goto WRITE-C1
call log %logger% I 输入分区名:%parname%
ECHOC {%c_h%}请选择要刷入的img文件...{%c_i%}{\n}& call sel file s %framework_workspace% [img]
ECHOC {%c_h%}请将设备进入系统, Recovery或Fastboot模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}模式错误, 请进入系统, Recovery或Fastboot模式. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 模式错误:%chkdev__mode%.应进入系统或Recovery或Fastboot模式& pause>nul & ECHO.重试... & goto WRITE-C1))
ECHO.正在将%sel__file_path%刷入%parname%(%chkdev__mode%)...& call write %chkdev__mode% %parname% %sel__file_path%
goto INFO-DONE
:WRITE-C2
ECHOC {%c_h%}请选择要启动的img文件...{%c_i%}{\n}& call sel file s %framework_workspace% [img]
ECHOC {%c_h%}请将设备进入Fastboot模式...{%c_i%}{\n}& call chkdev fastboot
ECHO.正在临时启动%sel__file_path%...& call write fastbootboot %sel__file_path%
goto WRITE-DONE
:WRITE-C3
ECHOC {%c_h%}请选择img文件所在目录...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
set searchpath=%sel__folder_path%
ECHOC {%c_h%}请选择rawprogram.xml文件...{%c_i%}{\n}& call sel file m %framework_workspace% [xml]
set xml=%sel__files%
ECHO.是否选择patch.xml文件? & ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择patch.xml文件...{%c_i%}{\n}& call sel file m %framework_workspace% [xml]
if "%choice%"=="1" set xml=%xml%/%sel__files%
set fh=
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl rechk 1
start framework logviewer start %logfile%
call write qcedlxml %chkdev__port__qcedl% auto %searchpath% %xml% %fh%
call framework logviewer end
goto WRITE-DONE
:WRITE-C4
ECHOC {%c_h%}请输入要刷入的分区名: {%c_i%}& set /p parname=
if "%parname%"=="" goto WRITE-C4
call log %logger% I 输入分区名:%parname%
ECHOC {%c_h%}请选择要刷入的img文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [img]
set imgpath=%sel__file_path%
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl
start framework logviewer start %logfile%
call write qcedl %parname% %imgpath% auto %fh%
call framework logviewer end
goto WRITE-DONE
:WRITE-C5
ECHOC {%c_h%}请选择要推送的文件...{%c_i%}{\n}& call sel file s %framework_workspace%
ECHO.1.普通   2.程序
call input choice [1][2]
if "%choice%"=="1" set type=common
if "%choice%"=="2" set type=program
:WRITE-C5-1
ECHOC {%c_h%}请将设备进入系统或Recovery模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" ECHOC {%c_e%}模式错误, 请进入系统或Recovery模式. {%c_h%}按任意键重试...{%c_i%}{\n}& pause>nul & ECHO.重试... & goto WRITE-C5-1)
ECHOC {%c_a%}正在推送...{%c_i%}{\n}& call write adbpush %sel__file_path% bff.test %type%
ECHO.推送完成. 位置为: %write__adbpush__filepath%
goto WRITE-DONE
:WRITE-C6
ECHOC {%c_h%}请选择QCN文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [qcn]
ECHOC {%c_h%}请将设备开机, 开启USB调试并同意Root权限申请...{%c_i%}{\n}& call chkdev system rechk 1
ECHO.开启高通基带调试模式... & call reboot system qcdiag rechk 1
call write qcdiag %chkdev__port__qcdiag% %sel__file_path%
goto WRITE-DONE
:WRITE-C7
ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
ECHOC {%c_h%}请将设备进入9008模式...{%c_i%}{\n}& call chkdev qcedl
call write qcedlsendfh %chkdev__port% %sel__file_path% auto
goto WRITE-DONE
:WRITE-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能WRITE& pause>nul & goto MENU


:SCRCPY
SETLOCAL
set logger=example.bat-scrcpy
call log %logger% I 进入功能SCRCPY
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.scrcpy.bat 投屏
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHOC {%c_h%}请将设备进入系统...{%c_i%}{\n}& call chkdev system
call scrcpy 测试投屏
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能SCRCPY& pause>nul & goto MENU


:CLEAN
SETLOCAL
set logger=example.bat-clean
call log %logger% I 进入功能CLEAN
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.clean.bat 清除
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.TWRP恢复出厂
ECHO.2.TWRP格式化Data
ECHO.3.格式化FAT32,NTFS或EXFAT
ECHO.4.高通9008擦除分区
call input choice [1][2][3][4]
goto CLEAN-C%choice%
:CLEAN-C1
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery rechk 3
call clean twrpfactoryreset
goto CLEAN-DONE
:CLEAN-C2
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery rechk 3
call clean twrpformatdata
goto CLEAN-DONE
:CLEAN-C3
ECHO.1.格式化为FAT32
ECHO.2.格式化为NTFS
ECHO.3.格式化为EXFAT
call input choice [1][2][3]
if "%choice%"=="1" set format=fat32
if "%choice%"=="2" set format=ntfs
if "%choice%"=="3" set format=exfat
ECHO.1.输入分区名字
ECHO.2.输入分区路径
call input choice [1][2]
goto CLEAN-C3-%choice%
:CLEAN-C3-1
ECHOC {%c_h%}输入分区名字按Enter继续: {%c_i%}& set /p choice=
if "%choice%"=="" goto CLEAN-C3-1
set var=name:%choice%& goto CLEAN-C3-A
:CLEAN-C3-2
ECHOC {%c_h%}输入分区路径按Enter继续: {%c_i%}& set /p choice=
if "%choice%"=="" goto CLEAN-C3-2
set var=path:%choice%& goto CLEAN-C3-A
:CLEAN-C3-A
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery
call clean format%format% %var%
goto CLEAN-DONE
:CLEAN-C4
ECHOC {%c_h%}输入分区名字按Enter继续: {%c_i%}& set /p parname=
if "%parname%"=="" goto CLEAN-C4
set fh=
ECHO.是否选择firehose引导文件? 选择则发送引导, 跳过则不发送& ECHO.1.选择   2.跳过& call input choice [1][2]
if "%choice%"=="1" ECHOC {%c_h%}请选择firehose引导文件...{%c_i%}{\n}& call sel file s %framework_workspace%\.. [elf][melf][mbn]
if "%choice%"=="1" set fh=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008...{%c_i%}{\n}& call chkdev qcedl
call clean qcedl %parname% %chkdev__port__qcedl% %fh%
goto CLEAN-DONE
:CLEAN-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能CLEAN& pause>nul & goto MENU


:THEME
SETLOCAL
set logger=example.bat-theme
call log %logger% I 进入功能THEME
:THEME-1
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.主题
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.默认
ECHO.2.经典
ECHO.3.乌班图
ECHO.4.抖音黑客
ECHO.5.流金
ECHO.6.DOS
ECHO.7.过年好
ECHO.A.返回主菜单
call input choice [1][2][3][4][5][6][7][A]
if "%choice%"=="1" set target=default
if "%choice%"=="2" set target=classic
if "%choice%"=="3" set target=ubuntu
if "%choice%"=="4" set target=douyinhacker
if "%choice%"=="5" set target=gold
if "%choice%"=="6" set target=dos
if "%choice%"=="7" set target=ChineseNewYear
if "%choice%"=="A" ENDLOCAL & call log %logger% I 完成功能THEME& goto MENU
::加载预览
call framework theme %target%
echo.@ECHO OFF>%tmpdir%\theme.bat
echo.mode con cols=50 lines=17 >>%tmpdir%\theme.bat
echo.cd ..>>%tmpdir%\theme.bat
echo.set path=%framework_workspace%;%framework_workspace%\tool\Win;%framework_workspace%\tool\Android;%path% >>%tmpdir%\theme.bat
echo.COLOR %c_i% >>%tmpdir%\theme.bat
echo.TITLE 主题预览: %target% >>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_i%}普通信息{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_w%}警告信息{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_e%}错误信息{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_s%}成功信息{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_h%}手动操作提示{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_a%}强调色{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.ECHOC {%c_we%}弱化色{%c_i%}{\n}>>%tmpdir%\theme.bat
echo.ECHO. >>%tmpdir%\theme.bat
echo.pause^>nul>>%tmpdir%\theme.bat
echo.EXIT>>%tmpdir%\theme.bat
call framework theme
start %tmpdir%\theme.bat
::加载预览完成
ECHO.
ECHO.已加载预览. 是否使用该主题
ECHO.1.使用   2.不使用
call input choice #[1][2]
if "%choice%"=="1" call framework conf user.bat framework_theme %target%& ECHOC {%c_i%}已更换主题, 重新打开脚本生效. {%c_h%}按任意键关闭脚本...{%c_i%}{\n}& call log %logger% I 更换主题为%target%& pause>nul & EXIT
if "%choice%"=="2" goto THEME-1


:SLOT
SETLOCAL
set logger=example.bat-slot
call log %logger% I 进入功能SLOT
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.slot.bat 槽位功能
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.检查当前槽位
ECHO.2.设置槽位
call input choice [1][2]
ECHOC {%c_h%}请将设备进入系统, Recovery或Fastboot模式...{%c_i%}{\n}& call chkdev all
if not "%chkdev__mode%"=="system" (if not "%chkdev__mode%"=="recovery" (if not "%chkdev__mode%"=="fastboot" ECHOC {%c_e%}模式错误, 请进入系统, Recovery或Fastboot模式. {%c_h%}按任意键重试...{%c_i%}{\n}& call log %logger% E 模式错误:%chkdev__mode%.应进入系统或Recovery或Fastboot模式& pause>nul & ECHO.重试... & goto SLOT))
goto SLOT-C%choice%
:SLOT-C1
call slot %chkdev__mode% chk
ECHO.[当前槽位:%slot__cur%] [当前槽位的另一槽位:%slot__cur_oth%] [当前槽位是否不可用:%slot__cur_unbootable%] [当前槽位的另一槽位是否不可用:%slot__cur_oth_unbootable%]
goto SLOT-DONE
:SLOT-C2
ECHOC {%c_h%}输入目标槽位按Enter继续: {%c_i%}& set /p choice=
call slot %chkdev__mode% set %choice%
goto SLOT-DONE
:SLOT-DONE
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能SLOT& pause>nul & goto MENU


:LOG
SETLOCAL
set logger=example.bat-log
call log %logger% I 进入功能LOG
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.开关日志
ECHO.=--------------------------------------------------------------------=
ECHO.
if "%framework_log%"=="y" (ECHO.1.[当前]开启日志) else (ECHO.1.      开启日志)
if "%framework_log%"=="n" (ECHO.2.[当前]关闭日志) else (ECHO.2.      关闭日志)
call input choice [1][2]
if "%choice%"=="1" call framework conf user.bat framework_log y
if "%choice%"=="2" call framework conf user.bat framework_log n
ECHO. & ECHOC {%c_s%}完成. {%c_i%}更改将在下次启动时生效. {%c_h%}按任意键返回主菜单...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能SLOT& pause>nul & goto MENU


:PARTABLE
SETLOCAL
set logger=example.bat-partable
call log %logger% I 进入功能PARTABLE
CLS
ECHO.=--------------------------------------------------------------------=
ECHO.partable.bat 分区表
ECHO.=--------------------------------------------------------------------=
ECHO.
ECHO.1.Recovery-删除和建立userdata分区
ECHO.2.Recovery-设置最大分区数
ECHO.3.Recovery-sgdisk备份分区表
ECHO.4.Recovery-sgdisk恢复分区表
ECHO.5.9008-回读GPT分区表
ECHO.6.9008-刷入GPT分区表
ECHO.A.返回主菜单
call input choice [1][2][3][4][5][6][A]
if "%choice%"=="A" ENDLOCAL & call log %logger% I 完成功能PARTABLE& goto MENU
goto PARTABLE-C%choice%
:PARTABLE-C1
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery
ECHO.正在读取分区信息... & call info par userdata
set diskpath_userdata=%info__par__diskpath%& set partype_userdata=%info__par__type%& set parstart_userdata=%info__par__start%& set parend_userdata=%info__par__end%& set parnum_userdata=%info__par__num%
ECHO. & adb.exe shell ./sgdisk -p %diskpath_userdata%& ECHO.
ECHO.按任意键开始删除... & pause>nul & ECHO.删除分区... & call partable recovery rmpar %diskpath_userdata% numb:%parnum_userdata%
ECHO. & adb.exe shell ./sgdisk -p %diskpath_userdata%& ECHO.
ECHO.按任意键开始建立... & pause>nul & ECHO.建立分区... & call partable recovery mkpar %diskpath_userdata% userdata %partype_userdata% %parstart_userdata% %parend_userdata% %parnum_userdata%
ECHO. & adb.exe shell ./sgdisk -p %diskpath_userdata%
ECHO. & ECHOC {%c_s%}完成. {%c_i%}更改将在下次启动时生效. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU
:PARTABLE-C2
ECHOC {%c_h%}输入目标磁盘路径按Enter继续: {%c_i%}& set /p diskpath=
if "%diskpath%"=="" goto PARTABLE-C2
ECHOC {%c_h%}输入最大分区数按Enter继续(默认128): {%c_i%}& set /p maxparnum=
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery
ECHO.正在设置最大分区数... & call partable recovery setmaxparnum %diskpath% %maxparnum%
ECHO. & ECHOC {%c_s%}完成. {%c_i%}更改将在下次启动时生效. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU
:PARTABLE-C3
ECHOC {%c_h%}输入目标磁盘路径按Enter继续: {%c_i%}& set /p diskpath=
if "%diskpath%"=="" goto PARTABLE-C3
ECHOC {%c_h%}请选择保存文件夹...{%c_i%}{\n}& call sel folder s %framework_workspace%\..
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery
ECHO.正在备份分区表到%diskpath% %sel__folder_path%\partable.bak... & call partable recovery sgdiskbakpartable %diskpath% %sel__file_path%\partable.bak
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU
:PARTABLE-C4
ECHOC {%c_h%}输入目标磁盘路径按Enter继续: {%c_i%}& set /p diskpath=
if "%diskpath%"=="" goto PARTABLE-C4
ECHOC {%c_h%}请选择分区表文件...{%c_i%}{\n}& call sel file s %framework_workspace%\..
ECHOC {%c_h%}请将设备进入Recovery...{%c_i%}{\n}& call chkdev recovery
ECHO.正在恢复分区表... & call partable recovery sgdiskrecpartable %diskpath% %sel__file_path%
ECHO. & ECHOC {%c_s%}完成. {%c_i%}更改将在下次启动时生效. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU
:PARTABLE-C5
ECHO.请选择回读的GPT分区表:
ECHO.0 1 2 3 4 5 6 7
call input choice [0][1][2][3][4][5][6][7]
set lunnum=%choice%
ECHO.1.main   2.backup
call input choice [1][2]
if "%choice%"=="1" set target=main
if "%choice%"=="2" set target=backup
ECHO.请选择文件保存位置... & call sel folder s %framework_workspace%\..
ECHO.请选择firehose... & call sel file s %framework_workspace%\.. [mbn][elf][melf]
ECHOC {%c_h%}请将设备进入9008...{%c_i%}{\n}& call chkdev qcedl
ECHO.正在回读GPT分区表... & call partable qcedl readgpt %chkdev__port% auto %lunnum% %target% %sel__folder_path%\gpt_%target%.bin notice %sel__file_path%
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU
:PARTABLE-C6
ECHO.请选择刷入的GPT分区表:
ECHO.0 1 2 3 4 5 6 7
call input choice [0][1][2][3][4][5][6][7]
set lunnum=%choice%
ECHO.1.main   2.backup
call input choice [1][2]
if "%choice%"=="1" set target=main
if "%choice%"=="2" set target=backup
ECHO.请选择GPT分区表文件... & call sel file s %framework_workspace%\.. [bin]
set gptpath=%sel__file_path%
ECHO.请选择firehose... & call sel file s %framework_workspace%\.. [mbn][elf][melf]
set fhpath=%sel__file_path%
ECHOC {%c_h%}请将设备进入9008...{%c_i%}{\n}& call chkdev qcedl
ECHO.正在刷入GPT分区表... & call partable qcedl writegpt %chkdev__port% auto %lunnum% %target% %gptpath% %fhpath%
ECHO. & ECHOC {%c_s%}完成. {%c_h%}按任意键返回...{%c_i%}{\n}& ENDLOCAL & call log %logger% I 完成功能PARTABLE& pause>nul & goto MENU




:FATAL
ECHO. & if exist tool\Win\ECHOC.exe (tool\Win\ECHOC {%c_e%}抱歉, 脚本遇到问题, 无法继续运行. 请查看日志. {%c_h%}按任意键退出...{%c_i%}{\n}& pause>nul & EXIT) else (ECHO.抱歉, 脚本遇到问题, 无法继续运行. 按任意键退出...& pause>nul & EXIT)
