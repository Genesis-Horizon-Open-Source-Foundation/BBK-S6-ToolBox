from PyQt5.QtGui import QColor

THEME_COLOR = QColor(24, 120, 210)
TEXT_PRIMARY = QColor(0, 0, 0)
TEXT_SECONDARY = QColor(100, 100, 100)
BUTTON_STYLE = """
PrimaryPushButton {
    min-width: 120px;
    min-height: 36px;
    font: 14px 'Microsoft YaHei';
}
"""
BAT_PATHS = {
    'root': r'src\\res\\s6root.bat',
    'twrp': r'src\\res\\fhtwrp.bat',
    'gsi': r'src\\res\\gsi_flash.bat'
}