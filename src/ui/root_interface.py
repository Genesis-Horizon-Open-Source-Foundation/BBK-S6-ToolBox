from PyQt5.QtCore import pyqtSignal
from qfluentwidgets import PrimaryPushButton, TitleLabel, ScrollArea
from qfluentwidgets import FluentIcon as FIF
import subprocess
import os

class RootInterface(ScrollArea):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName('RootInterface')
        
        self.label = TitleLabel('一键Root操作', self)
        self.btnRoot = PrimaryPushButton(FIF.COMMAND_PROMPT, '执行Root', self)
        self.btnRoot.clicked.connect(self.run_root_script)
        
        self.setWidget(self.label)
        self.setWidgetResizable(True)
        
        script_dir = os.path.join(os.path.dirname(__file__), '..', 'res')
        self.root_script = os.path.normpath(os.path.join(script_dir, 's6root.bat'))

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