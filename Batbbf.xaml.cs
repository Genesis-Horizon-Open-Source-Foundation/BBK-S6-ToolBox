using System.Windows;

namespace BBKS6玩机工具箱
{
    public partial class Batbbf : Window
    {
        public Batbbf()
        {
            InitializeComponent();
        }

        public void SetOutput(string text)
        {
            OutputTextBox.Text = text; // 假设 UI 中有名称为 OutputTextBox 的控件
        }

    }
    
}