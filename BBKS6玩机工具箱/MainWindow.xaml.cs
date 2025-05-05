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
        
        process.OutputDataReceived += (sender, e) => 
            outputBuilder.AppendLine(e.Data ?? string.Empty);
        process.ErrorDataReceived += (sender, e) => 
            outputBuilder.AppendLine(e.Data ?? string.Empty);

        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        
        await process.WaitForExitAsync();
        
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
