import os
import zipfile
import shutil
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QIcon
from qfluentwidgets import FluentWindow, NavigationItemPosition, SubtitleLabel, FluentIcon as FIF
from src.ui.home_interface import HomeInterface
from src.ui.root_interface import RootInterface
from src.ui.twrp_interface import TWRPInterface
from src.ui.gsi_interface import GSIInterface
from src.download_engine import DownloadEngine, ProgressBar


def check_and_download_resources():
    if getattr(sys, 'frozen', False):
        base_dir = os.path.dirname(sys.executable)
    else:
        base_dir = os.path.dirname(os.path.abspath(__file__))
    
    res_dir = os.path.join(base_dir, 'res')
    
    if not os.path.exists(res_dir) or not os.listdir(res_dir):
        print("资源文件夹不存在或为空，开始下载资源文件...")
        
        os.makedirs(res_dir, exist_ok=True)
        
        resource_url = "https://down.ghosf.dpdns.org/s6/ToolBox/s6-toolbox_res.zip"
        zip_path = os.path.join(res_dir, "s6-toolbox_res.zip")
        
        try:
            engine = DownloadEngine()
            progress_bar = ProgressBar()
            
            download_id = engine.start_download(resource_url, zip_path)
            
            print("正在下载资源文件...")
            
            while engine.is_downloading:
                progress_bar.update(download_id, engine)
                import time
                time.sleep(0.1)

            progress_bar.clear()
            
            if os.path.exists(zip_path):
                print("下载完成，正在解压...")
                
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(res_dir)
                
                os.remove(zip_path)
                
                print("资源文件准备完成！")
            else:
                print("下载失败，请检查网络连接")
                
        except Exception as e:
            print(f"下载资源文件时发生错误: {e}")
    else:
        print("资源文件夹已存在，跳过下载")


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
    check_and_download_resources()
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())