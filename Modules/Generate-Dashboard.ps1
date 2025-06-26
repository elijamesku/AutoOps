# Modules\Generate-Dashboard.ps1

$ticketsPath = ".\Logs\AutoOpsTickets.json"
$htmlPath = ".\Logs\AutoOpsDashboard.html"

if (-Not (Test-Path $ticketsPath)) {
    Write-Warning "No tickets found to generate report."
    exit 1
}

$tickets = Get-Content $ticketsPath | ConvertFrom-Json
$headerDate = Get-Date -Format "f"

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AutoOps Dashboard</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f6f8;
            color: #333;
            padding: 40px;
        }
        h2 {
            color: #0078D7;
            border-bottom: 2px solid #0078D7;
            padding-bottom: 8px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            margin-top: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        th, td {
            padding: 12px 15px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #0078D7;
            color: white;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #eef2f7;
        }
    </style>
</head>
<body>
    <h2>AutoOps Ticket Summary – $headerDate</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Device</th>
            <th>Time</th>
            <th>Issue</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
"@

foreach ($ticket in $tickets) {
    $html += @"
        <tr>
            <td>$($ticket.id)</td>
            <td>$($ticket.device)</td>
            <td>$($ticket.time)</td>
            <td>$($ticket.issue)</td>
            <td>$($ticket.status)</td>
            <td>$($ticket.action)</td>
        </tr>
"@
}

$html += @"
    </table>
</body>
</html>
"@

$html | Set-Content $htmlPath -Encoding UTF8
Write-Host "Dashboard generated at $htmlPath"
