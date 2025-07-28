from PyQt5.QtCore import pyqtSignal
from qfluentwidgets import PrimaryPushButton, TitleLabel, ScrollArea, MessageBox
from qfluentwidgets import FluentIcon as FIF
import subprocess
import os

class TWRPInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('TWRPInterface')
        
        self.label = TitleLabel('TWRP Recovery刷入', self)
        self.btnTWRP = PrimaryPushButton(FIF.DOWNLOAD, '刷入TWRP', self)
        self.btnTWRP.clicked.connect(self.run_twrp_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        script_dir = os.path.join(os.path.dirname(__file__), '..', 'res')
        self.twrp_script = os.path.normpath(os.path.join(script_dir, 'fhtwrp.bat'))

    def run_twrp_script(self):
        try:
            subprocess.Popen(
                self.twrp_script,
                shell=True,
                cwd=os.path.dirname(self.twrp_script)
            )
        except Exception as e:
            MessageBox('错误', f'TWRP刷入失败: {str(e)}', self).exec_()