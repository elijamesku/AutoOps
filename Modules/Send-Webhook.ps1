# Modules\Send-Webhook.ps1

function Send-AutoOpsWebhookReport {
    param (
        [string]$htmlPath = ".\Logs\AutoOpsDashboard.html"
    )

    $webhookUrl = "https://hooks.slack.com/services/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"

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
    }

    try {
        $jsonBody = $payload | ConvertTo-Json -Depth 10 -Compress
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonBody -ContentType "application/json"
        Write-Host "Report sent to Slack"
    } catch {
        Write-Warning "Webhook failed: $_"
    }
}

Send-AutoOpsWebhookReport
