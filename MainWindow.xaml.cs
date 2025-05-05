using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Text;

namespace BBKS6玩机工具箱
{
    public partial class MainWindow : Window, INotifyPropertyChanged
    {
        private string _deviceModel;
        private string _androidVersion;
        private string _serialNumber;
        private string _cpuInfo;
        private string _storageInfo;
        private string _advancedInfo;

        public event PropertyChangedEventHandler PropertyChanged;

        public string DeviceModel
        {
            get => _deviceModel;
            set { _deviceModel = value; OnPropertyChanged(nameof(DeviceModel)); }
        }

        public string AndroidVersion
        {
            get => _androidVersion;
            set { _androidVersion = value; OnPropertyChanged(nameof(AndroidVersion)); }
        }

        public string SerialNumber
        {
            get => _serialNumber;
            set { _serialNumber = value; OnPropertyChanged(nameof(SerialNumber)); }
        }

        public string CPUInfo
        {
            get => _cpuInfo;
            set { _cpuInfo = value; OnPropertyChanged(nameof(CPUInfo)); }
        }

        public string StorageInfo
        {
            get => _storageInfo;
            set { _storageInfo = value; OnPropertyChanged(nameof(StorageInfo)); }
        }

        public string AdvancedInfo
        {
            get => _advancedInfo;
            set { _advancedInfo = value; OnPropertyChanged(nameof(AdvancedInfo)); }
        }

        public MainWindow()
        {
            InitializeComponent();
            DataContext = this;
            Loaded += MainWindow_Loaded;
        }

        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            RefreshDeviceInfo();
        }

        private void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        private string ExecuteAdbCommand(string arguments)
        {
            try
            {
                string adbPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tools", "adb.exe");
                
                var process = new Process
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = adbPath,
                        Arguments = arguments,
                        UseShellExecute = false,
                        RedirectStandardOutput = true,
                        CreateNoWindow = true
                    }
                };

                process.Start();
                string output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();

                return output.Trim();
            }
            catch (Exception ex)
            {
                return $"错误: {ex.Message}";
            }
        }

        public void RefreshDeviceInfo()
        {
            SerialNumber = ExecuteAdbCommand("get-serialno");
            DeviceModel = ExecuteAdbCommand("shell getprop ro.product.model");
            AndroidVersion = ExecuteAdbCommand("shell getprop ro.build.version.release");
            CPUInfo = ExecuteAdbCommand("shell cat /proc/cpuinfo | grep model");
            StorageInfo = ExecuteAdbCommand("shell df -h");
            AdvancedInfo = ExecuteAdbCommand("shell getprop");
        }

        private void RefreshDeviceInfo_Click(object sender, RoutedEventArgs e)
        {
            RefreshDeviceInfo();
        }

        private void ExportDeviceInfo_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string exportPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), 
                    $"设备信息_{DateTime.Now:yyyyMMddHHmmss}.txt");
                
                string content = $"设备型号: {DeviceModel}\n" +
                                $"Android版本: {AndroidVersion}\n" +
                                $"序列号: {SerialNumber}\n" +
                                $"CPU信息: {CPUInfo}\n" +
                                $"存储信息: {StorageInfo}\n\n" +
                                $"完整信息:\n{AdvancedInfo}";
                
                File.WriteAllText(exportPath, content);
                MessageBox.Show($"设备信息已导出到: {exportPath}", "导出成功", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"导出失败: {ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void MenuItem_Open_Click(object sender, RoutedEventArgs e)
        {
            // TODO:打开文件功能
        }

        private void MenuItem_Save_Click(object sender, RoutedEventArgs e)
        {
            // TODO:保存文件功能
        }

        private void MenuItem_Exit_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }

        private void MenuItem_About_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("BBKS6玩机工具箱 v0.322\nAGPL - V3开源许可 © 2025", "关于");
            
        }
        private async void ExecuteBatFile(string batFileName)
        {
            var batbbfWindow = new Batbbf();
    
            try
            {
                var process = new Process();
                process.StartInfo.FileName = "cmd.exe";
                process.StartInfo.Arguments = $"/c \"{batFileName}\"";
                process.StartInfo.WorkingDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tools");
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.RedirectStandardError = true;
                process.StartInfo.CreateNoWindow = true;

                var outputBuilder = new StringBuilder();
        
                process.OutputDataReceived += (sender, e) 
                    => outputBuilder.AppendLine(e.Data ?? string.Empty);
                process.ErrorDataReceived += (sender, e) 
                    => outputBuilder.AppendLine(e.Data ?? string.Empty);

                process.Start();
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
        
                process.WaitForExit();
        
                batbbfWindow.SetOutput(outputBuilder.ToString());
            }
            catch (Exception ex)
            {
                batbbfWindow.SetOutput($"执行错误：{ex.Message}");
            }
    
            batbbfWindow.Show();
        }

        private void Function1_Click(object sender, RoutedEventArgs e)
        {
            ExecuteBatFile("function1.bat");
        }

        private void Function2_Click(object sender, RoutedEventArgs e)
        {
            ExecuteBatFile("function2.bat");
        }

    }
}
