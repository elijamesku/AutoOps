# AutoOps - Zero-Touch Automation Script
param(
    [ValidateSet("Install", "Uninstall")]
    [string]$Mode = "Install"
)

$ErrorActionPreference = 'Stop'

$configPath = ".\Config\AutoOps.json"
$ticketsPath = ".\Logs\AutoOpsTickets.json"
$logsPath = ".\Logs"

Write-Host "`n[MODE] Running AutoOps in $Mode mode."

# Load config
if (-Not (Test-Path $configPath)) {
    Write-Error "Config file not found: $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Ensure logs folder exists
if (-Not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}

# Ticket Generator
function New-AutoOpsTicket {
    param (
        [string]$AppName,
        [string]$Reason
    )

    $ticket = @{
        id      = Get-Random -Minimum 1000 -Maximum 9999
        time    = (Get-Date).ToString("s")
        device  = $env:COMPUTERNAME
        issue   = "Failed: $AppName"
        status  = "open"
        action  = $Reason
    }

    $existing = @()
    if (Test-Path $ticketsPath) {
        $existing = Get-Content $ticketsPath | ConvertFrom-Json
    }

    $existing += $ticket
    $existing | ConvertTo-Json -Depth 5 | Set-Content $ticketsPath
    Write-Host "[TICKET CREATED] $($ticket.issue)"
}

# Send Dashboard to Webhook
function Send-AutoOpsWebhookReport {
    param (
        [string]$webhookUrl,
        [string]$htmlPath = ".\Logs\AutoOpsDashboard.html"
    )

    if (-Not (Test-Path $htmlPath)) {
        Write-Warning "HTML report not found."
        return
    }

    $htmlContent = Get-Content $htmlPath -Raw
    $snippet = $htmlContent.Substring(0, [Math]::Min(1000, $htmlContent.Length)) -replace '`', "'"

    $payload = @{
        username = "AutoOps Bot"
        text     = "AutoOps Report Generated: $(Get-Date -Format g)"
        attachments = @(
            @{
                fallback = "AutoOps HTML Report"
                color    = "#0078D7"
                title    = "View AutoOps Dashboard"
                text     = $snippet
            }
        )
    } | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
        Write-Host "Report sent to webhook"
    } catch {
        Write-Warning "Webhook failed: $_"
    }
}

# Compliance Checker
function Invoke-AutoComplianceCheck {
    Write-Host "`n[RUNNING COMPLIANCE AUDIT]"
    $issues = @()

    # Defender
    try {
        $defender = Get-MpPreference
        if ($defender.DisableRealtimeMonitoring) {
            $issues += "Windows Defender real-time protection is OFF"
        }
    } catch {
        $issues += "Unable to query Defender status"
    }

    # Firewall
    $firewall = Get-NetFirewallProfile
    if ($firewall.Enabled -contains $false) {
        $issues += "One or more firewall profiles are DISABLED"
    }

    # Disk Space
    $drive = Get-PSDrive -Name C
    if ($drive.Free -lt 10GB) {
        $issues += "Low disk space: Less than 10GB free on drive C:"
    }

    # BitLocker
    try {
        $bitlocker = Get-BitLockerVolume -MountPoint "C:"
        if ($bitlocker.VolumeStatus -ne 'FullyEncrypted') {
            $issues += "BitLocker is NOT fully enabled on C:"
        }
    } catch {
        $issues += "Unable to query BitLocker status on C:"
    }

    foreach ($issue in $issues) {
        New-AutoOpsTicket -AppName "Compliance" -Reason $issue
        Write-Warning "[COMPLIANCE ISSUE] $issue"
    }

    if ($issues.Count -eq 0) {
        Write-Host "[COMPLIANT] All checks passed."
    }
}

# ========== MAIN LOGIC ==========

if ($Mode -eq "Install") {
    foreach ($app in $config.apps) {
        Write-Host "`n[INSTALLING] $($app.name)..."

        $ext = if ($app.install_url -like "*.msi*") { "msi" } else { "exe" }
        $downloadPath = "$env:TEMP\$($app.name).$ext"

        try {
            Invoke-WebRequest -Uri $app.install_url -OutFile $downloadPath -UseBasicParsing

            if ($ext -eq "msi") {
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" $($app.silent_args)" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath $downloadPath -ArgumentList $app.silent_args -Wait -NoNewWindow
            }

            Write-Host "[SUCCESS] Installed $($app.name)"
        } catch {
            Write-Warning "[FAILED] $($app.name) - $($_.Exception.Message)"
            New-AutoOpsTicket -AppName $app.name -Reason $_.Exception.Message
        }
    }

    Invoke-AutoComplianceCheck
}

elseif ($Mode -eq "Uninstall") {
    foreach ($app in $config.apps) {
        Write-Host "`n[UNINSTALLING] $($app.name)..."

        try {
            if ($app.uninstall_string) {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($app.uninstall_string)" -Wait -NoNewWindow
                Write-Host "[SUCCESS] Uninstalled $($app.name)"
            } else {
                Write-Warning "[SKIPPED] $($app.name) has no uninstall string defined"
                New-AutoOpsTicket -AppName $app.name -Reason "Missing uninstall string"
            }
        } catch {
            Write-Warning "[FAILED] $($app.name) - $($_.Exception.Message)"
            New-AutoOpsTicket -AppName $app.name -Reason $_.Exception.Message
        }
    }

    Write-Host "`n[UNINSTALL MODE COMPLETE]"
    exit 0
}

# Register scheduled task to run every 14 days
$taskName = "AutoOps Every 14 Days"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if (-not $taskExists) {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSScriptRoot\\Run-AutoOps.ps1`""
    $trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 14 -At 9am
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Runs AutoOps every 14 days" | Out-Null
    Write-Host "[INFO] Scheduled task '$taskName' registered."
} else {
    Write-Host "[INFO] Scheduled task already exists."
}
Write-Host "`n[AutoOps Completed]"
# ==== Generate HTML Dashboard ====
try {
    Write-Host "`n[INFO] Generating AutoOps Dashboard..."
    & "$PSScriptRoot\Modules\Generate-Dashboard.ps1"
    Write-Host "[SUCCESS] Dashboard generated."
} catch {
    Write-Warning "[ERROR] Failed to generate dashboard: $_"
}

# ==== Send Dashboard to Webhook ====
try {
    Write-Host "`n[INFO] Sending dashboard to webhook..."
    & "$PSScriptRoot\Modules\Send-Webhook.ps1"
    Write-Host "[SUCCESS] Dashboard sent."
} catch {
    Write-Warning "[ERROR] Failed to send dashboard: $_"
}
