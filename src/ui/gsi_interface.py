from PyQt5.QtCore import Qt
from qfluentwidgets import PrimaryPushButton, TitleLabel, ScrollArea, MessageBox
from qfluentwidgets import FluentIcon as FIF
import subprocess
import os

class GSIInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('GSIInterface')
        
        self.label = TitleLabel('刷写第三方GSI镜像', self)
        self.btnGSI = PrimaryPushButton(FIF.CLOUD, '执行刷写', self)
        self.btnGSI.clicked.connect(self.run_gsi_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        script_dir = os.path.join(os.path.dirname(__file__), '..', 'res')
        self.gsi_script = os.path.normpath(os.path.join(script_dir, 's6superroot\gsi_flash.bat'))

    def run_gsi_script(self):
        try:
            subprocess.Popen(
                self.gsi_script,
                shell=True,
                cwd=os.path.dirname(self.gsi_script)
            )
        except Exception as e:
            MessageBox('错误', f'GSI刷写失败: {str(e)}', self).exec_()