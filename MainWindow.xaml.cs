using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;

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
        
        private void LogExecution(string filePath, string result)
        {
            string logPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "execution_log.txt");
            string logEntry = $"[{DateTime.Now}] Executed: {filePath}\r\nResult: {result}\r\n\r\n";
            File.AppendAllText(logPath, logEntry);
        }

        private void MenuItem_Open_Click(object sender, RoutedEventArgs e)
{
    var openFileDialog = new Microsoft.Win32.OpenFileDialog
    {
        Filter = "BAT files (*.bat)|*.bat|All files (*.*)|*.*"
    };
    
    if (openFileDialog.ShowDialog() == true)
    {
        try
        {
            // 使用系统默认方式执行BAT文件
            var process = new Process();
            process.StartInfo.FileName = openFileDialog.FileName;
            process.StartInfo.UseShellExecute = true;  
            process.StartInfo.Verb = "runas";          
            process.Start();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"执行失败：{ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}


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

        private async Task<string> ExecuteAdbCommandAsync(string arguments)
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
                        CreateNoWindow = true,
                        StandardOutputEncoding = Encoding.UTF8
                    }
                };

                var outputBuilder = new StringBuilder();
        
                using (process)
                {
                    process.Start();
                    string output = await process.StandardOutput.ReadToEndAsync();
                    await Task.Run(() => process.WaitForExit()); 
            
                    return output.Trim();
                }
            }
            catch (Exception ex)
            {
                return $"错误: {ex.Message}";
            }
        }


        public async void RefreshDeviceInfo()
        {
            SerialNumber = await ExecuteAdbCommandAsync("get-serialno");
            DeviceModel = await ExecuteAdbCommandAsync("shell getprop ro.product.model");
            AndroidVersion = await ExecuteAdbCommandAsync("shell getprop ro.build.version.release");
            CPUInfo = await ExecuteAdbCommandAsync("shell cat /proc/cpuinfo | grep model");
            StorageInfo = await ExecuteAdbCommandAsync("shell df -h");
            AdvancedInfo = await ExecuteAdbCommandAsync("shell getprop");
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
        


        private void ExecuteBatFileDirectly(string batFileName)
        {
            string batFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tools", batFileName);
    
            if (!File.Exists(batFilePath))
            {
                MessageBox.Show($"文件不存在：{batFilePath}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
    
            try
            {
                var process = new Process();
                process.StartInfo.FileName = batFilePath;
                process.StartInfo.UseShellExecute = true;  
                process.StartInfo.Verb = "runas";          
                process.Start();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"执行失败：{ex.Message}", "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Function1_Click(object sender, RoutedEventArgs e)
        {
            ExecuteBatFileDirectly("s6root.bat");
        }

        private void Function2_Click(object sender, RoutedEventArgs e)
        {
            ExecuteBatFileDirectly("fhtwrp.bat");
        }
    }
}