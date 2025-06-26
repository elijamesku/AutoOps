Add-Type -AssemblyName PresentationFramework

# Create Window
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2024/xaml/presentation"
        Title="AutoOps GUI" Height="220" Width="400" WindowStartupLocation="CenterScreen">
    <Grid Margin="10">
        <StackPanel>
            <TextBlock Text="Choose AutoOps Mode:" FontSize="16" Margin="0,0,0,10"/>
            <Button Name="InstallBtn" Content="Run Install Mode" Height="40" Margin="0,0,0,10"/>
            <Button Name="UninstallBtn" Content="Run Uninstall Mode" Height="40" Margin="0,0,0,10"/>
            <Button Name="DashboardBtn" Content="Generate Dashboard Only" Height="40"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Button Handlers
$window.FindName("InstallBtn").Add_Click({
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-AutoOps.ps1`" -Mode Install"
    $window.Close()
})
$window.FindName("UninstallBtn").Add_Click({
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Run-AutoOps.ps1`" -Mode Uninstall"
    $window.Close()
})
$window.FindName("DashboardBtn").Add_Click({
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Modules\Generate-Dashboard.ps1`""
    $window.Close()
})

# Show GUI
$window.ShowDialog() | Out-Null
