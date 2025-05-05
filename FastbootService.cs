using System;
using System.Diagnostics;

namespace BBKS6玩机工具箱
{
    public class FastbootService
    {
        public string FastbootCommand { get; set; }
        public string FastbootOutput { get; private set; }

        public FastbootService()
        {
            FastbootCommand = string.Empty;
            FastbootOutput = string.Empty;
        }

        public void ExecuteCommand()
        {
            if (string.IsNullOrWhiteSpace(FastbootCommand))
            {
                FastbootOutput = "错误: 命令不能为空";
                return;
            }

            try
            {
                Process process = new Process();
                process.StartInfo.FileName = "fastboot";
                process.StartInfo.Arguments = FastbootCommand;
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.RedirectStandardError = true;
                process.StartInfo.CreateNoWindow = true;

                process.Start();
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                process.WaitForExit();

                FastbootOutput = string.IsNullOrEmpty(error) ? output : error;
            }
            catch (Exception ex)
            {
                FastbootOutput = $"执行命令时出错: {ex.Message}";
            }
        }

        public void RebootToFastboot()
        {
            FastbootCommand = "reboot fastboot";
            ExecuteCommand();
        }
    }
}