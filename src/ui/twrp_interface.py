from PyQt5.QtCore import pyqtSignal
from qfluentwidgets import PrimaryPushButton, TitleLabel, ScrollArea, MessageBox
from qfluentwidgets import FluentIcon as FIF
import subprocess
import os
import sys

def get_resource_path():
    if getattr(sys, 'frozen', False):
        base_dir = os.path.dirname(sys.executable)
    else:
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_dir, 'res')

class TWRPInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('TWRPInterface')
        
        self.label = TitleLabel('TWRP Recovery刷入', self)
        self.btnTWRP = PrimaryPushButton(FIF.DOWNLOAD, '刷入TWRP', self)
        self.btnTWRP.clicked.connect(self.run_twrp_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        res_dir = get_resource_path()
        self.twrp_script = os.path.normpath(os.path.join(res_dir, 'fhtwrp.bat'))

    def run_twrp_script(self):
        try:
            subprocess.Popen(
                self.twrp_script,
                shell=True,
                cwd=os.path.dirname(self.twrp_script)
            )
        except Exception as e:
            MessageBox('错误', f'TWRP刷入失败: {str(e)}', self).exec_()