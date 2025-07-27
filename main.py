from qfluentwidgets import FluentWindow, NavigationItemPosition, SubtitleLabel
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QPushButton
import os

class ToolBox(FluentWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('EEBBK S6 玩机工具箱')
        self.resize(900, 600)

        # 创建子界面
        self.homeInterface = QWidget()
        self.fastbootInterface = QWidget()
        self.adbInterface = QWidget()
        self.otherInterface = QWidget()

        self.initNavigation()
        self.initInterfaces()

    def initNavigation(self):
        self.addSubInterface(self.homeInterface, 'home', '首页', position=NavigationItemPosition.TOP)
        self.addSubInterface(self.fastbootInterface, 'lightning', 'Fastboot工具', position=NavigationItemPosition.SCROLL)
        self.addSubInterface(self.adbInterface, 'code', 'ADB工具', position=NavigationItemPosition.SCROLL)
        self.addSubInterface(self.otherInterface, 'menu', '其他功能', position=NavigationItemPosition.BOTTOM)

    def initInterfaces(self):
        # 首页
        home_layout = QVBoxLayout(self.homeInterface)
        home_layout.addWidget(SubtitleLabel('欢迎使用 EEBBK S6 工具箱', self))
        home_layout.setAlignment(Qt.AlignTop)

        # Fastboot工具界面
        self.createToolButtons(self.fastbootInterface, [
            ('进入Fastboot模式', 'fastboot_enter'),
            ('退出Fastboot模式', 'fastboot_exit'),
            ('刷写Recovery', 'flash_recovery')
        ])

        # ADB工具界面
        self.createToolButtons(self.adbInterface, [
            ('启用ADB调试', 'adb_enable'),
            ('无线ADB连接', 'adb_wireless'),
            ('重启到Recovery', 'reboot_recovery')
        ])

        # 其他功能界面
        self.createToolButtons(self.otherInterface, [
            ('备份分区表', 'backup_partitions'),
            ('恢复分区表', 'restore_partitions'),
            ('清除设备数据', 'wipe_data')
        ])

    def createToolButtons(self, parent, buttons):
        layout = QVBoxLayout(parent)
        for text, bat_name in buttons:
            btn = QPushButton(text)
            btn.setFixedHeight(45)
            btn.clicked.connect(lambda _, name=bat_name: self.runBatScript(name))
            layout.addWidget(btn)
        layout.addStretch(1)

    def runBatScript(self, name):
        bat_path = os.path.join(os.getcwd(), 'src', 'res', f'{name}.bat')
        if os.path.exists(bat_path):
            os.startfile(bat_path)
        else:
            print(f'脚本文件 {bat_path} 不存在')

if __name__ == '__main__':
    import sys
    from PyQt5.QtWidgets import QApplication
    
    app = QApplication(sys.argv)
    window = ToolBox()
    window.show()
    sys.exit(app.exec_())