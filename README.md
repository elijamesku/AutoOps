![PowerShell](https://img.shields.io/badge/Built%20With-PowerShell-5391FE?logo=powershell)
![Windows](https://img.shields.io/badge/Platform-Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)

# AutoOps (Local Automation Framework for IT Ops)
This system is a modular PowerShell based automation suite that simulates enterprise grade IT workflows including software compliance checks, dashboard generation, webhook alerts, and zero-touch execution... without requiring Intune or any MDM


This is a framework designed to emulate real world IT operations, scale across devices, and serve as a live demo of automation first IT administration

```                                
       __        __   _                            _          _   _            ____  _____    _    ____  __  __ _____ 
       \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___   | |_| |__   ___  |  _ \| ____|  / \  |  _ \|  \/  | ____|
        \ \ /\ / / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \  | __| '_ \ / _ \ | |_) |  _|   / _ \ | | | | |\/| |  _|  
         \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) | | |_| | | |  __/ |  _ <| |___ / ___ \| |_| | |  | | |___ 
          \_/\_/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/   \__|_| |_|\___| |_| \_\_____/_/   \_\____/|_|  |_|_____|
                                                                                                                                                                              
                                                                                                
```

## Why AutoOps Exists
Manual compliance checks, software auditing, and ticket simulation are often time consuming and error prone. AutoOps solves this by:

- Silent installation of applications(EXE/MSI)
- Compliance auditing (Defender, Firewall, Disk, BitLocker)
- JSON based config
- Webhook alerts (e.g. Slack)
- Auto generated HTML dashboards
- Ticket simulation for failed installs
- Scheduled execution every 14 days
- Works offline with local logs

  
## Project Structure
```
C:\AutoOps
├── Config\
│   └── AutoOps.json                 # Main configuration file
├── Logs\
│   ├── AutoOpsDashboard.html       # Auto-generated compliance dashboard
│   ├── AutoOpsTickets.json         # Simulated helpdesk tickets
│   └── DeviceRefreshSchedule.json  # Sample output data
├── Modules\
│   ├── Generate-Dashboard.ps1      # Builds the HTML dashboard from logs
│   ├── Run-ComplianceOnly.ps1      # Performs compliance checks
│   └── Send-Webhook.ps1            # Sends log summaries to webhook
├── Launch-AutoOpsGUI.ps1           # (Planned) GUI entrypoint --- will improve on
└── Run-AutoOps.ps1                 # Main entry point
```
## How to Run AutoOps
- Open PowerShell as Administrator

- Navigate to the AutoOps root folder:

```
cd "C:\AutoOps"
```
Run the main entry point:
```
.\Run-AutoOps.ps1
```  
![Screenshot 1](https://github.com/elijamesku/AutoOps/blob/main/Images/Screenshot%202025-06-25%20192515.png?raw=true)  

You can also run modules individually for testing:

```
.\Modules\Run-ComplianceOnly.ps1
.\Modules\Generate-Dashboard.ps1
.\Modules\Send-Webhook.ps1
```

## Configuration
The AutoOps.json file defines which modules to run and how they behave.

Example:
```json
{
  "modulesToRun": [
    "Run-ComplianceOnly",
    "Generate-Dashboard",
    "Send-Webhook"
  ],
  "webhookUrl": "https://yourdomain.com/webhook-endpoint",
  "outputDirectory": "C:\\AutoOps\\Logs"
}
```
## Output (Live Examples)
AutoOps Dashboard
![Screenshot 2](https://github.com/elijamesku/AutoOps/blob/main/Images/Screenshot%202025-06-25%20192624.png?raw=true)

## JSON Ticket Output
```json
{
  "TicketID": "AUTO-1543",
  "User": "ejames",
  "Module": "Run-ComplianceOnly",
  "Status": "Completed",
  "Time": "2025-06-25T19:24:00"
}
```
![Screenshot 3](https://github.com/elijamesku/AutoOps/blob/main/Images/Screenshot%202025-06-25%20192741.png?raw=true)  
![Screenshot 4](https://github.com/elijamesku/AutoOps/blob/main/Images/Screenshot%202025-06-25%20192755.png?raw=true) 

## Refresh Schedule Output  
```json
{
  "LastRun": "2025-06-25T17:02:00",
  "NextRun": "2025-07-09T17:00:00",
  "Tasks": [
    "Compliance Scan",
    "Webhook Dispatch",
    "Dashboard Rebuild"
  ]
}
```
## Features
- JSON-driven config execution

- HTML dashboard generation

- PowerShell-native logging and modularity

- Simulated helpdesk ticket output

- Webhook alert dispatch

- Scalable design for future Intune or Azure integration

## Use Cases
- Test and simulate compliance engines

- Centralize logs in real-time

- Automate software lifecycle steps (future module)

## Requirements
- Windows 10 or 11

- PowerShell 5.1+ (or 7+)

- Admin rights for scheduled tasks and installations

## Coming soon...
- GUI module selector (WPF/WinForms)

- Azure Log Analytics integration

- Real time webhook alerts (Teams/Slack)

- Scheduled execution via Task Scheduler

- Auto-merge of logs for historical trend analysis

## License
This project is licensed under the MIT License.

```                                        
             |  _ \ _____      _____ _ __ ___  __| | | |__  _   _    ___ _   _ _ __(_) ___  ___(_) |_ _   _ 
             | |_) / _ \ \ /\ / / _ \ '__/ _ \/ _` | | '_ \| | | |  / __| | | | '__| |/ _ \/ __| | __| | | |
             |  __/ (_) \ V  V /  __/ | |  __/ (_| | | |_) | |_| | | (__| |_| | |  | | (_) \__ \ | |_| |_| |
             |_|   \___/_\_/\_/ \___|_|  \___|\__,_| |_.__/ \__, |  \___|\__,_|_|  |_|\___/|___/_|\__|\__, |
                   | ____| (_)                              |___/                                     |___/ 
              _____|  _| | | |                                                                              
             |_____| |___| | |                                                                              
                   |_____|_|_|                                                                              
```
