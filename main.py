from PyQt5.QtCore import Qt
from PyQt5.QtGui import QIcon
from qfluentwidgets import FluentWindow, NavigationItemPosition, SubtitleLabel, FluentIcon as FIF
from src.ui.home_interface import HomeInterface
from src.ui.root_interface import RootInterface
from src.ui.twrp_interface import TWRPInterface
from src.ui.gsi_interface import GSIInterface

class MainWindow(FluentWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('S6 Flash Toolbox')
        self.setWindowIcon(QIcon('icon.png'))
        self.resize(800, 600)

        # 创建子界面
        self.homeInterface = HomeInterface(self)
        self.rootInterface = RootInterface(self)
        self.twrpInterface = TWRPInterface(self)
        self.gsiInterface = GSIInterface(self)

        # 添加导航项
        self.addSubInterface(self.homeInterface, FIF.HOME, '主页')
        self.addSubInterface(self.rootInterface, FIF.COMMAND_PROMPT, '一键Root')
        self.addSubInterface(self.twrpInterface, FIF.DOWNLOAD, '刷入TWRP')
        self.addSubInterface(self.gsiInterface, FIF.CLOUD, '刷写GSI')

if __name__ == '__main__':
    import sys
    from PyQt5.QtWidgets import QApplication

    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())