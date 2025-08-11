from PyQt5.QtCore import Qt
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

class GSIInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('GSIInterface')
        
        self.label = TitleLabel('刷写第三方GSI镜像', self)
        self.btnGSI = PrimaryPushButton(FIF.CLOUD, '执行刷写', self)
        self.btnGSI.clicked.connect(self.run_gsi_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        res_dir = get_resource_path()
        self.gsi_script = os.path.normpath(os.path.join(res_dir, 'FH_GSI', 'fh_gsi.exe'))

    def run_gsi_script(self):
        try:
            subprocess.Popen(
                self.gsi_script,
                shell=True,
                cwd=os.path.dirname(self.gsi_script)
            )
        except Exception as e:
            MessageBox('错误', f'GSI刷写失败: {str(e)}', self).exec_()