from PyQt5.QtCore import pyqtSignal
from qfluentwidgets import PrimaryPushButton, TitleLabel, ScrollArea
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

class RootInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('RootInterface')
        
        self.label = TitleLabel('一键Root操作', self)
        self.btnRoot = PrimaryPushButton(FIF.COMMAND_PROMPT, '执行Root', self)
        self.btnRoot.clicked.connect(self.run_root_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        res_dir = get_resource_path()
        self.root_script = os.path.normpath(os.path.join(res_dir, 's6root.bat'))

    def run_root_script(self):
        try:
            subprocess.Popen(
                self.root_script, 
                shell=True,
                cwd=os.path.dirname(self.root_script)
            )
        except Exception as e:
            from qfluentwidgets import MessageBox
            MessageBox('错误', f'执行失败: {str(e)}', self).exec_()