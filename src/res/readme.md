版本：1.5  
# BFF简介
bat刷机框架（Bat Framework for Flashing，简称BFF）是一个主要由bat脚本编写，以一些命令行工具和Linux程序为辅助的，为制作bat刷机工具提供便利的框架。  
BFF拥有以下优点：  
- 模块化：将刷机操作整合成模块，可以轻松调用。  
- 规范化：所有模块按照统一规则编写，避免屎山。  
- 工具丰富：提供制作bat刷机工具常用的各种工具，包括文件选择器，管理员申请工具等等。  
- 用户友好：屏蔽原始输出，避免杂乱；使用不同颜色的文字代表不同含义，更加直观；支持主题，可自定义配色方案。  
- 完善的实现方法：BFF在一些操作上使用了更完善的实现方法，具有更好的兼容性。  
- 严格的错误处理：BFF有严格的错误处理机制，包括启动自检，关键步骤的报错检测，分级日志系统等。尽力保证及时报告每个问题。  
# 鸣谢  
- affggh（酷安@affggh）
- 终不似曾尘世闲游（酷安@终不似曾尘世闲游）
- 小太阳ACA（酷安@小太阳ACA）
- 无敌战神领主（酷安@无敌战神领主）
- JV（Github@JVFCN）
- 其他所有贡献者
- ...
# 特别提示  
- 建议使用“克隆/下载”-“下载ZIP”来下载最新源码。发行版中的可能不是最新版本。  
- 由于Gitee不同步我的换行符更改，下载解压后需要先检查和更改所有脚本换行符，否则会闪退。详见本说明“关于脚本编码和换行符”一章。  
- 如果你是bat脚本开发者，希望得到关于BFF的帮助或提供反馈、建议，请在Gitee，酷安或B站私聊我（某贼），加入BFF开发群。  
# 目录和文件介绍  
- 📂.vscode：vscode编辑器配置文件(不需要可删除)
- 📂bin：工作目录，存放框架文件
  - 📂conf：配置文件夹，存放配置文件
    - 📄fixed.bat：固定配置文件
    - 📄user.bat：用户配置文件
  - 📂tmp：临时文件文件夹，存放临时文件
  - 📂log：日志文件夹，存放日志
  - 📂tool：工具文件夹，存放调用的命令行工具等
    - 📂Android：安卓工具
    - 📂Win：Windows工具
    - 📄logo.txt：字符画形式的标志，在启动时展示
  - 📄calc.bat：计算模块
  - 📄chkdev.bat：检查设备连接模块
  - 📄clean.bat：清除模块
  - 📄dl.bat：下载模块
  - 📄framework.bat：框架相关功能模块
  - 📄imgkit.bat：分区镜像处理模块
  - 📄info.bat：设备信息读取处理模块
  - 📄input.bat：文本输入模块
  - 📄log.bat：日志模块
  - 📄open.bat：打开模块
  - 📄partable.bat：分区表模块
  - 📄random.bat：随机数模块
  - 📄read.bat：读出（分区镜像等）模块
  - 📄reboot.bat：重启模块
  - 📄scrcpy.bat：adb投屏模块
  - 📄sel.bat：选择文件（夹）模块
  - 📄slot.bat：槽位模块
  - 📄write.bat：写入（分区镜像等）模块
- 📄cmd.bat：命令行
- 📄readme.md：说明文档
- 📄example.bat：使用BFF制作工具箱的示例
# 模块介绍  
### 关于模块传入参数的特别说明
由于涉及不到复杂的应用场景，模块的参数设计比较简单，就是按照第一个，第二个，第三个的顺序来识别的，中间以空格作为分隔。可选的参数会放在最后，以保证留空不选也不会影响其他参数的识别。模块没有对传入参数是否合法的检查，如果用错了就会按照错误的参数错误地执行下去，所以在使用模块前，请务必查看模块调用方法，按照规定的参数调用。参数内不能有空格，尽量不要带特殊符号。  
### calc（计算模块）
**简介**  
用于精确计算。使用计算工具calc.exe和比较大小工具numcomp.exe以弥补bat自带计算功能的不足（如数值不能过大、不能计算小数等）。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|
|-|-|-|-|-|-|-|-|
|两数相加|将计算结果赋值给指定的输出变量|call calc|p|输出变量名|nodec<br>nodec-intp1<br>dec-保留小数位数|数字1|数字2|
|两数相减|同上|同上|s|同上|同上|同上|同上|
|两数相乘|同上|同上|m|同上|同上|同上|同上|
|两数相除|同上|同上|d|同上|同上|同上|同上|
|byte值转扇区值|同上|同上|b2sec|同上|同上|b|扇区大小|
|扇区值转byte值|同上|同上|sec2b|同上|同上|扇区数目|扇区大小|
|byte值转KiB值|同上|同上|b2kb|同上|同上|b||
|KiB值转byte值|同上|同上|kb2b|同上|同上|kb||
|...|||||||
|比较两数大小|calc__numcomp__result（比较大小结果）：greater，less，equal|同上|numcomp|数字1|数字2|||
 
nodec：若计算结果有小数，则直接去掉  
nodec-intp1：若计算结果有小数，则直接去掉，且整数部分+1  
dec-保留小数位数：按照指定的位数保留计算结果小数  
BFF中所有kb，mb，gb简写均代表KiB，MiB，GiB，也就是使用1024进制。BFF中所有存储大小数值均默认以字节（byte）为单位传递和计算。比如xxx_size=233，就默认233为233字节。如果需要使用其他单位，建议在原变量名后面加上“_单位”以免混淆，如xxx_size_gb=xxx。  
**示例**  
将扇区值“666”转为byte值，不保留小数，输出到result变量：  
`call calc sec2b result nodec 666 4096`  
计算6乘9，保留两位小数，输出到result变量：  
`call calc m result dec-2 6 9`  
比较123和456的大小，如果123小于456则打印“小于”：  
`call calc numcomp 123 456`  
`if "%calc__numcomp__result%"=="less" ECHO.小于`  
### chkdev（检查设备连接模块）  
**简介**  
用于检查各个模式的设备连接，确保连接正常。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|
|-|-|-|-|-|-|
|检查系统连接|chkdev__mode（已连接设备的模式）：参数1中的模式名称<br>chkdev__port（已连接设备的端口号）：端口号数字<br>chkdev__port__模式（已连接设备的端口号）：端口号数字|call chkdev|system|[可选]rechk|[可选]复查前等待秒数|
|检查Recovery模式连接|同上|同上|recovery|同上|同上|
|检查ADBSideload模式连接|同上|同上|sideload|同上|同上|
|检查Fastboot模式连接|同上|同上|fastboot|同上|同上|
|检查FastbootD模式连接|同上|同上|fastbootd|同上|同上|
|检查高通9008模式连接|同上|同上|qcedl|同上|同上|
|检查高通基带调试模式连接|同上|同上|qcdiag|同上|同上|
|检查展讯深度刷机模式连接|同上|同上|sprdboot|同上|同上|
|检查联发科brom模式连接|同上|同上|mtkbrom|同上|同上|
|检查联发科preloader模式连接|同上|同上|mtkpreloader|同上|同上|
|检查以上所有模式连接（高通基带调试模式除外）|同上|同上|all|同上|同上|

检查规则：1，检查不到目标设备就不退出模块，一直循环检查。2，不支持多设备，只允许一个目标设备连接。3，大约30秒检测不到则超时，超时后会暂停并提示用户按任意键重新检测（端口设备除外，端口设备无限等待直到设备连接）。  
当某操作在不同模式下均可完成时，可以使用“检查所有模式”并根据检查到的模式使用不同方法完成该操作，方便快捷。  
由于基带调试模式只用于调试基带，故不在“检查所有模式”范围内。  
默认调用一次模块只检查一次连接，但由于在某些特殊情况下设备连接不稳定，故提供复查（rechk）功能，可以等待指定的秒数后再次检查目标连接，减少短时间内的连接不稳定导致的问题。等待秒数可以自行设置，若不设置则默认3秒。若不复查则无需填写等待秒数。  
已连接设备为端口时才会涉及端口号。否则不涉及端口号。端口号为纯数字，默认为COM端口。  
**示例**  
检查系统连接：  
`call chkdev system`  
检查所有连接，如果Fastboot模式已连接则打印“Fastboot”：  
`call chkdev all`  
`if "%chkdev__mode%"=="fastboot" ECHO.Fastboot`  
检查所有连接并复查(默认等待3秒)：  
`call chkdev all rechk`  
检查Recovery连接并在6秒后复查：  
`call chkdev recovery rechk 6`  
### clean（清除模块）  
**简介**  
包括清除，擦除，格式化等操作。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|
|-|-|-|-|-|-|-|
|twrp执行恢复出厂（双清）命令||call clean|twrpfactoryreset|||
|twrp执行格式化data命令||同上|twrpformatdata|||
|格式化指定分区为fat32||同上|formatfat32|name:分区名<br>path:分区路径|[可选]卷标|
|格式化指定分区为ntfs||同上|formatntfs|同上|同上|
|格式化指定分区为exfat||同上|formatexfat|同上|同上|
|格式化指定分区为ext4||同上|formatext4|同上|同上|
|9008擦除指定分区||同上|qcedl|分区名|端口号数字<br>auto|[可选]firehose路径(留空则不发送引导)|

在formatfat32，formatntfs，formatexfat和formatext4中，目标分区可以以分区名或分区路径的形式指定。如果使用分区名，则在分区名前加上“name:”，使用路径则加上“path:”。卷标可选，不填则不设置。  
**示例**  
格式化Data：  
`call clean twrpformatdata`  
将abc分区格式化为fat32格式：  
`call clean formatfat32 name:abc`  
将dev/block/sda23格式化为ntfs格式，并设置卷标为Windows：  
`call clean formatntfs path:dev/block/sda23 Windows`  
### dl（下载模块）  
**简介**  
从直链或蓝奏云分享链接下载文件。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|参数6|
|-|-|-|-|-|-|-|-|-|
|从直链下载|dl__result（下载结果）：y（成功），n（失败）|call dl|direct|直链|完整文件保存路径(包括文件名)|retry<br>once|notice<br>noprompt|[可选]检查字符串|
|从蓝奏云分享链接下载|同上|同上|lzlink|蓝奏分享链接|同上|同上|同上|同上|

支持下载直链或蓝奏云分享链接。  
其中蓝奏云分享链接支持分卷压缩包下载。如果是分卷压缩包，在填写蓝奏分享链接时以[分卷1链接][分卷2链接][分卷3链接]...格式填写即可。会一次性下载全部分卷。  
模块有“只尝试下载一次”（once）和“自动重试”（retry）两种下载模式。  
当目标位置已存在同名文件时，可以设置提示等待确认（notice）或不提示直接覆盖（noprompt）。  
针对文本类下载内容，下载完成后可以在下载内容中搜索自定义字符串以检验下载是否成功。  
下载完成后，传出下载是否成功（y或n）。  
注意：下载的文件名和网上原本的文件名没有关系，因为下载后要统一重命名为参数中设定的文件名。另外如果要下载的是一套分卷压缩包，文件名写.001前面的即可，下载后会自动添加.001等分卷后缀名。  
**示例**  
下载某直链：  
`call dl direct 直链链接 C:\test.zip once notice`  
下载某直链，如果目标文件存在则直接覆盖：  
`call dl direct 直链链接 C:\test.zip once noprompt`  
下载某直链txt文档并以下载的文件中是否有“syxz”字符串来检查是否下载成功：  
`call dl direct 直链链接 C:\test.txt once notice syxz`  
下载某蓝奏链接：  
`call dl lzlink 蓝奏分享链接 C:\test.zip once notice`  
下载一套蓝奏上的分卷压缩包：  
`call dl lzlink [001的蓝奏分享链接][002的][003的][...] C:\test.zip notice once`  
### framework（框架相关功能模块）  
**简介**  
包含框架本身的一些功能，如启动准备工作等。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|
|-|-|-|-|-|-|-|
|启动准备工作|winver（当前Windows版本号）<br>framework_workspace（工作目录完整路径）<br>tmpdir（临时文件目录完整路径）<br>logfile（日志文件完整路径）<br>logger（日志记录者，此处预设为UNKNOWN）|call framework|startpre|
|准备adb shell环境||同上|adbpre|程序名或all|
|加载主题||同上|theme|主题名|
|写入配置||同上|conf|要写入的配置文件名|要写入的变量名|要写入的变量值|
|关闭日志实时监控||同上|logviewer|end|
|开启日志实时监控||start framework|logviewer|start|%logfile%|

启动准备工作（startpre）是每次启动前都必须执行的，包括设置path，检查各个命令和命令行工具能否正常使用，准备日志系统等，不执行准备则无法正常使用框架。  
准备adb shell环境（adbpre）是将框架内置的Linux程序推送到设备中并授权，以便后续执行。可以选择只推送指定的程序或推送全部程序。可以在系统(需Root)或Recovery下使用，如在系统下，程序将被推送到./data/local/tmp/目录，如在Recovery下，则推送到根目录（./）。  
加载主题（theme）是根据指定的主题名字加载相关配色方案。如果参数中指定了正确的主题名字，则加载该主题，如果指定的主题名字不正确，则加载默认主题，如果没有指定参数，则加载conf\user.bat内设定的主题。  
写入配置（conf）是向指定配置文件写入指定配置信息。相比于直接echo，使用此功能可以自动移除该配置文件中的同名的旧配置信息，以保证旧信息不会一直累积。  
开关日志实时监控（logviewer）是开启或关闭当前日志文件的实时监控窗口。日志监控是用busybox的tail命令实现的。注意：关闭窗口采用的方法是直接结束bysybox-bfflogviewer.exe。  
**示例**  
完成启动准备工作：  
`call framework startpre`  
推送blktool并授权：  
`call framework adbpre blktool`  
加载默认主题：  
`call framework theme default`  
向conf\custom.bat中写入“set bff=nb”这条配置信息：  
`call framework conf custom.bat bff nb`  
开启当前日志的实时监控：  
`start framework logviewer start %logfile%`  
关闭日志实时监控：  
`call framework logviewer end`  
### imgkit（分区镜像处理模块）  
**简介**  
分区镜像处理模块。用于解包，修改，合成分区镜像。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|
|-|-|-|-|-|-|-|-|
|Magisk修补|imgkit__magiskpatch__vername（本次修补使用的面具的显示版本）<br>imgkit__magiskpatch__ver（本次修补使用的面具的版本号）|call imgkit|magiskpatch|需要修补的Boot文件完整路径|新Boot文件保存路径(包括文件名)|Magisk apk或zip路径|[可选]noprompt|
|为Recovery和Boot分区合并的boot.img注入Recovery||同上|recinst|需要修补的Boot文件完整路径|新Boot文件保存路径(包括文件名)|recovery文件完整路径(可以是img或ramdisk.cpio)|[可选]noprompt|
|处理frp文件以开启或关闭系统OEM解锁开关||同上|patchfrp|需要处理的frp文件路径|新frp文件保存路径(包括文件名)|oemunlockon<br>oemunlockoff|[可选]noprompt|
|处理vbmeta文件以禁用或启用校验||同上|patchvbmeta|需要处理的vbmeta文件路径|新vbmeta文件保存路径(包括文件名)|noverify<br>verify|[可选]noprompt|
|sparse格式镜像转换raw格式||同上|sparse2raw|sparse文件路径|raw文件保存路径(包括文件名)|[可选]noprompt|

当输出位置已存在同名文件时，脚本默认会提示并暂停，可以添加noprompt参数用于不提示默认覆盖。  
**示例**  
无  
### info（读取设备信息模块）  
**简介**  
执行读取设备信息相关操作。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|
|-|-|-|-|-|-|
|adb读信息|info__adb__product（设备代号）<br>info__adb__androidver（安卓版本）<br>info__adb__sdkver（sdk版本）|call info|adb|
|fastboot读信息|info__fastboot__product（设备代号）<br>info__fastboot__unlocked（BL锁是否已解锁）：yes，no|同上|fastboot|
|9008读信息|info__qcedl__memtype（存储类型）：ufs，emmc<br>info__qcedl__secsize（扇区大小）<br>info__qcedl__lunnum（lun数目）|同上|qcedl|端口号数字<br>auto|[可选]firehose路径(留空则不发送引导)
|读取指定分区信息|info__par__exist（分区是否存在）：y，n<br>info__par__diskpath（分区所在磁盘路径）<br>info__par__num（分区编号）<br>info__par__path（分区路径）<br>info__par__type（分区类型）<br>info__par__start（分区start）<br>info__par__end（分区end）<br>info__par__size（分区大小）<br>info__par__disksecsize（分区所在磁盘扇区大小）<br>info__par__disktype（分区所在磁盘类型）：ufs，emmc|同上|par|分区名|fail或back(当找不到分区时的操作.可选.默认为fail)|
|读取设备磁盘存储信息|info__disk__type（磁盘类型）：ufs，emmc<br>info__disk__secsize（磁盘扇区大小）<br>info__disk__maxparnum（磁盘最大分区数）|同上|disk|磁盘路径|

fastboot读取的设备代号很可能不准确，建议用adb读代号。  
使用par功能读取分区信息前，会先检查目标分区是否存在，如果不存在默认会提示失败。可以通过增加“back”参数使找不到分区后不提示失败，正常返回主脚本。  
注：默认输入和输出单位为byte，进制为1024（详见calc模块）。  
**示例**  
获取boot分区信息：  
`call info par boot`  
### input（文本输入模块）  
**简介**  
在菜单下面使用，提示用户输入选项并检查用户的输入是否合法，最终输出用户的选项。  
**功能说明**  

|功能|输出|调用|参数1|参数2|
|-|-|-|-|-|
|请求用户输入选项|choice（用户选项）<br>input__choice（用户选项）|call input|choice|[1][22]#[A][B]...(可选)|

choice功能：  
适用于一般的有多个选项的菜单。可以通过增加[1][22]...参数限定哪些选项为合法，只有用户输入的选项在[]内时才允许继续，否则会提示用户重新输入。在此基础上，还可以指定一个选项为默认选项（即用户无需输入任何选项，直接按回车即选择该项）。在[]前面加#即将该选项设为默认选项，例如[1]#[2][3]中，2即为默认选项。  
在填写限定选项参数时，如果涉及字母，一律使用大写。且无论用户输入的是大写还是小写，统一以大写输出。   
**示例**  
`ECHO.1.刷入Boot`  
`ECHO.2.刷入Recovery`  
`ECHO.A.查看说明`  
`call input choice [1][2]#[A]`  
`if "%choice%"="1" xxx`  
`if "%choice%"="2" xxx`  
`if "%choice%"="A" xxx`  
### log（日志模块）  
**简介**  
向当前日志文件（logfile）写日志。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|
|-|-|-|-|-|-|
|向当前日志文件（logfile）写日志||call log|日志记录者|I（信息）<br>W（警告）<br>E（错误）<br>F（崩溃）|日志内容(不能带有空格和英文逗号)|

向当前日志文件（logfile）写日志（logfile是在启动准备工作中设置的）。在调用时需要指定记录者、级别和内容。其中记录者指的是哪个模块要求记录的这个日志，可以直接填模块名来指定，在记录操作较多时也可以预先设置logger为模块名，然后统一使用%logger%。级别可以填I，W，E，F四个等级，分别指“信息”，“警告”，“错误”，“崩溃”。  
**示例**  
由example.bat记录“xxx文件将被覆盖”的警告信息：  
`call log example.bat W xxx文件将被覆盖`  
### open（打开模块）  
**简介**  
以指定的方式打开指定文件。  
**功能说明**  

|功能|输出|调用|参数1|参数2|
|-|-|-|-|-|
|通用方式打开||call open|common|目标路径|
|文件夹方式打开||同上|folder|同上|
|文本方式打开||同上|txt|同上|
|图片方式打开||同上|pic|同上|

打开文本调用的是Notepad3，打开图片调用的是Vieas。  
**示例**  
打开a.jpg：  
`call open pic a.jpg`  
### partable（分区表模块）  
**简介**  
读写修改分区表相关操作。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|参数6|参数7|参数8|参数9|
|-|-|-|-|-|-|-|-|-|-|-|-|
|Recovery模式下创建分区||call partable|recovery|mkpar|磁盘路径|分区名|分区类型|start|end:xxx(默认)或size:xxx|[可选]编号(留空则默认使用首个可用的)|
|Recovery模式下删除分区||同上|recovery|rmpar|磁盘路径|name:分区名<br>numb:分区编号|
|Recovery模式下设置最大分区数||同上|recovery|setmaxparnum|磁盘路径|[可选]目标分区数(留空则默认设为128)|
|Recovery模式下使用sgdisk备份分区表||同上|recovery|sgdiskbakpartable|磁盘路径|备份文件保存路径(包括文件名)|[可选]noprompt|
|系统模式下使用sgdisk备份分区表（需Root）||同上|system|sgdiskbakpartable|磁盘路径|备份文件保存路径(包括文件名)|[可选]noprompt|
|Recovery模式下使用sgdisk恢复备份的分区表||同上|recovery|sgdiskrecpartable|磁盘路径|备份文件路径|  
|9008模式下读分区表||同上|qcedl|readgpt|端口号数字<br>auto|ufs<br>emmc<br>spinor<br>auto|目标lun编号|main<br>backup|文件保存路径|notice（当备份文件保存位置存在同名文件时，暂停并警告）<br>noprompt（当备份文件保存位置存在同名文件时，直接覆盖，不提示）|[可选]firehose路径(留空则不发送引导)|
|9008模式下写分区表||同上|qcedl|writegpt|端口号数字<br>auto|ufs<br>emmc<br>spinor<br>auto|目标lun编号|main<br>backup|分区表文件路径|[可选]firehose路径(留空则不发送引导)|

**示例**  
无  
### random（随机数模块）  
**简介**  
按要求生成随机数。  
**功能说明**  

|功能|输出|调用|参数1|参数2|
|-|-|-|-|-|
|生成随机数|random_str|call random|随机数位数|[可选]指定字符池(留空则默认为所有小写字母和数字)|

**示例**  
在1-9所有数字范围内，生成一个4位随机数：  
`call random 4 123456789`  
### read（读出模块）  
**简介**  
用于读出（分区镜像等）操作。注意：这不是读信息。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|参数6|
|-|-|-|-|-|-|-|-|-|
|系统下读出分区镜像（需Root）||call read|system|分区名|文件保存路径(包括文件名)|[可选]noprompt|
|Recovery模式下读出分区镜像||同上|recovery|同上|同上|同上|
|9008模式下按照分区名读出分区镜像||同上|qcedl|同上|同上|noprompt<br>notice|端口号数字<br>auto|[可选]firehose完整路径(留空则不发送引导)|
|9008模式下按照xml读出分区镜像||同上|qcedlxml|端口号数字<br>auto|存储类型：ufs，emmc，auto|img存放文件夹|xml路径|[可选]firehose完整路径(留空则不发送引导)|
|高通基带调试模式下读出qcn||同上|qcdiag|端口号数字<br>auto|文件保存路径(包括文件名)|[可选]noprompt|
|使用adb从设备内拉取文件||同上|adbpull|源文件路径|文件保存路径(包括文件名)|[可选]noprompt|

**示例**  
系统下读出boot分区镜像到C:\Users\boot.img：  
`call read system boot C:\Users\boot.img`  
### reboot（重启模块）  
**简介**：  
重启设备到指定模式。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|
|-|-|-|-|-|-|-|
|从系统重启到指定模式||call reboot|system|system<br>recovery<br>fastboot<br>fastbootd<br>qcedl<br>qcdiag<br>sprdboot<br>poweroff|[可选]是否检查或复查目标模式连接：chk，rechk|[可选]如果上一个参数是rechk，则可以指定复查间隔秒数|
|从Recovery模式重启到指定模式||同上|recovery|system<br>recovery<br>fastboot<br>fastbootd<br>qcedl<br>sideload<br>sprdboot<br>poweroff|同上|同上|
|从Fastboot模式重启到指定模式||同上|fastboot|system<br>recovery<br>fastboot<br>fastbootd<br>qcedl<br>poweroff|同上|同上|
|从FastbootD模式重启到指定模式||同上|fastbootd|system<br>fastboot<br>fastbootd|同上|同上|
|从9008模式重启到指定模式||同上|qcedl|system<br>recovery<br>fastbootd<br>qcedl|同上|同上|

“system”代表开机，重启到system即为正常开机。  
从9008重启的功能默认不发送引导，端口号默认自动识别。  
一些重启方案不一定适合所有机型，比如Fastboot重启到Recovery等，如果当前方案不合适，则需要修改本模块。  
如果重启失败或重启结果检测错误，则提示用户手动选择操作（重试或跳过）。  
**示例**  
从Recovery重启到Fastboot：  
`call reboot recovery fastboot`  
从Recovery重启到Fastboot并随后检查Fastboot连接：  
`call reboot recovery fastboot chk`  
从Recovery重启到Fastboot并随后检查Fastboot连接，然后间隔6秒复查：  
`call reboot recovery fastboot rechk 6`  
### scrcpy（投屏模块）  
**简介**  
开机状态下ADB投屏。  
**功能说明**  

|功能|输出|调用|参数1|参数2|
|-|-|-|-|-|
|启动投屏||call scrcpy|窗口标题|[可选]wait(填wait为等待模式,留空则不等待)|

两种启动模式：启动后等待投屏窗口关闭再继续运行脚本，和启动后正常继续不等待。提示：为了避免文件占用冲突，不等待模式下scrcpy的运行日志会单独输出到log\scrcpy.log。  
**示例**  
启动ADB投屏（不等待）：  
`call scrcpy ADB投屏`  
### sel（选择文件或文件夹模块）  
**简介**  
打开文件或文件夹选择器，请用户选择并输出选择结果。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|
|-|-|-|-|-|-|-|
|选择文件（单选）|sel__file_path（已选文件完整路径）<br>sel__file_fullname（已选文件完整文件名）<br>sel__file_name（已选文件不包括扩展名的文件名）<br>sel__file_ext（已选文件扩展名）<br>sel__file_folder（已选文件所在文件夹路径）|call sel|file|s（单选）|打开时展示的文件夹的路径|[可选][img][bin]...|
|选择文件（多选）|sel__files（所有已选文件完整路径的集合）<br>sel__files_folder（已选文件所在文件夹路径）<br>sel__files_num（已选文件总数）|call sel|file|m（多选）|打开时展示的文件夹的路径|[可选][img][bin]...|
|选择文件夹（单选）|sel__folder_path（已选文件夹完整路径）<br>sel__folder_name（已选文件夹名）|同上|folder|s（单选）|打开时展示的文件夹的路径|
|选择文件夹（多选）|sel__folders（所有已选文件夹完整路径的集合）<br>sel__folders_num（已选文件夹总数）|同上|folder|m（多选）|打开时展示的文件夹的路径|

选择的文件或文件夹路径中不允许出现空格和英文括号，因为这两种符号可能造成脚本运行错误。  
在多选模式中，所有已选文件或文件夹的完整路径将连在一起输出，中间以“/”分隔。  
**示例**  
选择一个img文件：  
`call sel file s %framework_workspace% [img]`  
选择一个img或bin文件：   
`call sel file s %framework_workspace% [img][bin]`  
选择一个文件夹：  
`call sel folder s %framework_workspace%`  
### slot（槽位模块）  
**简介**  
查看和设置槽位，适用于ab分区的设备。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|
|-|-|-|-|-|-|
|设置槽位||call slot|system<br>recovery<br>fastboot<br>fastbootd<br>auto（自动识别设备当前模式）|set|a<br>b<br>cur<br>cur_oth|
|查看槽位|slot__cur（当前槽位）<br>slot__cur_oth（当前槽位的另一槽位）|同上|同上|chk|

系统下设置槽位需要Root权限，且有可能不生效。  
**示例**  
查看当前槽位：  
`call slot auto chk`  
在Fastboot模式查看当前槽位：  
`call slot fastboot chk`  
切换到另一槽位：  
`call slot auto set cur_oth`  
切换到槽位a：  
`call slot auto set a`  
### write（写入模块）  
**简介**  
用于写入（分区镜像等）操作。  
**功能说明**  

|功能|输出|调用|参数1|参数2|参数3|参数4|参数5|参数6|
|-|-|-|-|-|-|-|-|-|
|在系统下写入（需Root权限）||call write|system|分区名|分区镜像文件路径|
|在Recovery模式下写入||同上|recovery|同上|同上|
|在Fastboot模式下写入||同上|fastboot|同上|同上|
|在FastbootD模式下写入||同上|fastbootd|同上|同上|
|在9008模式下按分区名写入||同上|qcedl|同上|同上|端口号数字<br>auto|
|在Fastboot模式下临时启动||同上|fastbootboot|分区镜像文件路径|
|在9008模式下按xml写入||同上|qcedlxml|端口号数字<br>auto|存储类型：ufs，emmc|img所在文件夹(即搜索路径)|xml路径|[可选]firehose路径(留空则不发送引导)|
|在9008模式下发送引导||同上|qcedlsendfh|端口号数字<br>auto|firehose路径|[可选]配置端口方式，默认auto：auto（自动），emmc，ufs，spinor，skip（跳过配置端口）|
|在高通基带调试模式下写入qcn||同上|qcdiag|端口号数字<br>auto|qcn文件路径|
|在TWRP下使用twrpinstall方法安装卡刷包||同上|twrpinst|卡刷包路径|
|在ADBSideload模式下安装卡刷包||同上|sideload|卡刷包路径|
|ADB推送文件到设备内|write__adbpush__filepath（adb推送到设备中的完整文件路径）<br>write__adbpush__filename_full（完整文件名）<br>write__adbpush__filename（不包括扩展名的文件名）<br>write__adbpush__folder（文件所在文件夹路径）<br>write__adbpush__ext（文件扩展名）|同上|adbpush|源文件路径|推送后文件名|[可选]文件类型，留空则默认common：common（一般文件），program（程序）|

使用9008模式下按xml写入功能时，xml路径参数支持一次性指定多个xml，每个xml路径之间用/分隔（而不是fh_loader默认的英文逗号）。这和sel.bat多选文件的输出格式是一致的。  
关于ADB推送功能，推送到设备内的位置是自动决定的，并会在完成后输出文件路径等相关数据。common模式推送时，会检查文件大小以确保文件没有在推送过程中损坏。以program模式推送时，则不检查大小以节约时间。会授权目标程序（777）以便执行。  

**示例**  
系统下写入xxx\boot.img到boot分区：  
`call write system boot xxx\boot.img`  
Fastboot临时启动xxx\boot.img：  
`call write fastbootboot xxx\boot.img`  
# 日志系统介绍  
日志系统在framework模块的startpre（即启动准备）功能里完成准备。包括设定日志文件相对路径（logfile），记录电脑系统版本号、处理器架构、工作目录，清理日志（超过最大允许的日志数时）等。所以框架每次启动都会在log文件夹里生成一个日志文件，之后本次启动调用的所有模块和功能也都会统一将日志追加输出到这个文件。  
日志不仅要记录框架本身的日志，也要记录关键命令的原始输出。所以一般使用“1>>%logfile% 2>&1”将原始输出全部输出到日志文件。如果脚本需要读取原始输出中的信息，可以先覆盖输出到%tmpdir%\output.txt，读取信息后再type %tmpdir%\output.txt>>%logfile%。
# 变量命名和使用规则  
为避免变量杂乱和重名冲突，特别制定此规则。  
框架中的变量分为全局变量和局部变量。一些通用的变量，比如框架版本号、日志文件路径等，是设置为全局变量的。而模块运行时内部产生的临时变量则应作为局部变量，避免干扰全局变量。如果模块需要输出某些变量作为运行结果，则必须以“模块名__功能名__变量名”的格式输出，以和全局变量区分。注意是两个“_”而不是一个。  
命名变量时，应避免使用以下名字：  
path；time；errorlevel；date；ver；logfile；logger；tmpdir；winver；args1；args2；args3；args4；args5；args6；args7；args8；args9；  
临时变量可以使用以下名字：  
var；target；num；size；times；result；等。  
# 配置文件规则  
配置文件均位于conf文件夹，分为固定配置（fixed.bat）和用户配置（user.bat）两种。固定配置存放不允许用户自定义的配置信息，如框架版本号等。用户配置存放允许用户自定义的配置信息，如是否开启日志等。这样设计是为了方便在线更新，更新时只需要覆盖固定配置而跳过用户配置即可。注意：用户配置中所有项目都必须在使用它的相关脚本中设置当其值为空时的默认值或处理方法，确保即使user.bat被删除也不影响脚本运行。  
框架自身的配置项目如下：  
固定配置（fixed.bat）：  
framework_ver：框架版本号  
用户配置（user.bat）：  
framework_theme：主题名称。默认值为default  
framework_log：是否开启日志。默认值为y  
framework_lognum：最多保留几个日志文件。默认值为8  
framework_multitmpdir：是否启用多开模式。默认值为n  
配置项目均为全局变量，由主脚本在启动过程中加载（具体过程请参考example.bat）。  
如需向指定配置文件写入配置项目，请使用framework模块的conf功能。  
如需增加配置文件，请将配置文件置于conf文件夹并在主脚本启动过程的加载配置部分增加加载该文件。  
# 颜色和主题  
BFF中，不同颜色代表不同含义。默认情况下，亮白（F）代表普通提示信息，淡黄（E）代表警告信息，淡红（C）代表错误或崩溃信息，淡绿（A）代表操作成功信息，淡紫（D）提示手动操作（即需要用户手动操作时使用淡紫色）。此外，也用淡黄（E）代表强调的提示信息，灰白（7）代表弱化的提示信息。  
BFF使用变量替代颜色代码，从而使BFF支持应用自定义的配色方案，也就是“主题”。提示类型和变量名的对应关系如下：  

|提示类型|对应变量名|
|-|-|
|普通提示信息|%c_i%|
|警告信息|%c_w%|
|错误或崩溃信息|%c_e%|
|操作成功信息|%c_s%|
|手动操作|%c_h%|
|强调色|%c_a%|
|弱化色|%c_we%|

为这些变量赋值相应的颜色代码是在framework.bat的THEME功能完成的。相关调用方法详见framework.bat模块简介。如果需要自定义主题，也需要修改THEME中的脚本。  
# 关于脚本编码和换行符  
BFF中所有bat脚本都以GB2312或GB18030编码，换行符为CRLF。下载后请检查编码和换行符，以免出现问题。  
# 如何使用BFF制作一个刷机工具  
首先下载BFF并解压缩。找到example.bat，这是一个主脚本示例。将它复制一份，改名为你的工具名，编辑，将脚本中主菜单MENU以及之后的内容全部删除。上面的内容属于框架的启动步骤，有些可以修改，有些不能修改，具体请参照注释。完成启动步骤后就可以在下面编写你的脚本了。  
BFF将许多常用的刷机操作做成了模块，在涉及这些操作时，只需按照要求调用模块即可。实际执行命令的是模块，主脚本只起一个引领作用。  
BFF在tool里集成了很多工具，但你可能不一定都需要。具体是否需要请参照模块介绍中的“使用工具”一栏。如果确认不需要某工具，可以将其删除，然后在framework.bat的startpre功能中将该工具相关的检查项注释掉。注意，删除错误会导致脚本无法正常运行。
