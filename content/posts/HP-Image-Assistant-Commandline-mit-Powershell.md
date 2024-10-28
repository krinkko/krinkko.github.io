---
title: "HP Image Assistant Commandline Mit Powershell"
date: 2024-08-28T11:24:30+02:00
tags: ["Scripting","HP","Device Management","Powershell"]
categories: "Adminkram"
draft: false
description: "HP hat einen Image Assistant, den man mehr oder weniger bequem der Commandline nutzen kann."
---
Nachdem ich mich nun den Vormittag mit der an sich tollen Idee der Remoteausführung von [HP Image Assistant](https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HPIA.html) via Powershell auseinandergesetzt habe, hier mal meine 2ct dazu.

Ich hatte vor ein Script zu machen, welches mir erst einmal ausliest welche Treiber und Programme für ein bestimmtes Gerät verfügbar sind und welche Windows Update vielleicht nicht gesehen hat. Es gibt danach eine .html-Datei aus, in der die fehlenden oder aktualisierbaren Komponenten aufgelistet werden.

<b>Update 28.10.2024:</b> Die aktuelle Form des Scrips:

```powershell
param (
    [bool]$analyse = 1,
    [bool]$update = 0,
    [bool]$silent = 1
)

Start-Transcript -Path "C:\hpia\logs\hpia-script.log" -Force

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = "C:\HPIA\Logs\HPIA_analyze.log",
        [string]$LogLevel = "INFO"
    )

    # Ensure the log directory exists
    $logDir = [System.IO.Path]::GetDirectoryName($LogFile)
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force
    }

    # Create a timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format the log message
    $logMessage = "$timestamp [$LogLevel] - $Message"

    # Write the log message to the log file
    Add-Content -Path $LogFile -Value $logMessage
}

$logpath = "C:\HPIA\Logs\" #Oder Netzwerkpfad

if (Test-Path -Path D:\) {
    $downloadfolder = "D:\MEINPFAD\Treiber"
    } else {
    $downloadfolder = "C:\HPIA\Downloads\"
    }

if (Test-Path -Path 'C:\HPIA\HP Image Assistant\HPImageAssistant.exe') {
    $assistantfilepath = 'C:\HPIA\HP Image Assistant\HPImageAssistant.exe'
    $assistantversion = "5.3.0.506"
    $currentversion = (Get-Command $assistantfilepath).FileVersionInfo.FileVersion
    if ($currentversion -lt $assistantversion) {
       if (Test-Path -Path "NETWORKPATH\HP\hp-hpia-5.3.0.exe") {
            Start-Process "NETWORKPATH\HP\hp-hpia-5.3.0.exe" -ArgumentList "/s /e /f `"C:\HPIA\HP Image Assistant`"" -wait
       }
    }
} else {
    if (Test-Path -Path "NETWORKPATH\HP\hp-hpia-5.3.0.exe") {
        Start-Process "NETWORKPATH\HP\hp-hpia-5.3.0.exe" -ArgumentList "/s /e /f `"C:\HPIA\HP Image Assistant`"" -wait
    }
}


if (-not (Test-Path -Path $logpath)) {
    try {
    $reportfolder = new-item -Path "$($logpath)" -ItemType Directory -ErrorAction Continue
    } catch { Write-Host "Error." }
}

    if ($analyse -eq $true) {
        $args = @(
            "/Operation:Analyze",
            "/Silent",
            "/AutoCleanup",
            "/Action:List",
            "/reportfolder:$($logpath)"
        )
    Start-Process "C:\HPIA\HP Image Assistant\HPImageAssistant.exe" -argumentlist $args -wait
    }

    if ($update -eq $true) {
        if ($silent -eq $true) {
            $args = @(
                "/Auto",
                "/Category:All",
                "/selection:all",
                "/AutoCleanup",
                "/Silent",
                "/reportfolder:$($logpath)",
                "/SoftpaqDownloadFolder:$($downloadfolder)"
            )
        } else {
            $args = @(
                "/Auto",
                "/Category:All",
                "/selection:all",
                "/AutoCleanup",
                "/Noninteractive",
                "/reportfolder:$($logpath)",
                "/SoftpaqDownloadFolder:$($downloadfolder)"
            )
        }
	try {
		$updateresult = Start-Process "C:\HPIA\HP Image Assistant\HPImageAssistant.exe" -argumentlist $args -wait
        write-log -message "$($updateresult)" -errorcode "INFO"
	} catch {
		$errorcode = $_
		Write-Log -Message "$($errorcode)" -errorcode "ERROR" -LogFile "$($logpath)\HPIA-analyze.log"
	}

    # Energiespareinstellungen normalisieren
        #Aktiviert wieder das Ausbalancierte Schema
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 # Selective USB Energiesparen Batteriebetrieben
        powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 # Selective USB Energiesparen am Ladegerät
        powercfg /change monitor-timeout-ac 0
        powercfg /change monitor-timeout-dc 20
        powercfg /change standby-timeout-dc 60
        powercfg /change standby-timeout-ac 0
        powercfg /S SCHEME_CURRENT
        powercfg /h off
        
        $latest = get-childitem -path C:\hpia\logs | Where-Object {$_.Name -Like "*Readme*"} | Sort-Object LastAccessTime -Descending | Select-Object -First 1

        $mailadmin = "adminmail@bla.de"
        $mailfrom = "noreply@bla.de"
        $mailserver = "smtp.server.de"
        $mailsubject = "HP Image Assistant Log for $($env:computername)"
        $mailbody = "See HP Image Assistant Log attached to this email." 
        try {
            Send-MailMessage -BodyAsHtml -body $mailbody -To $mailadmin -From $mailfrom -Encoding UTF8 -SmtpServer $mailserver -Subject $mailsubject -Attachments "$($latest.FullName)"
        } catch {
            $errorcode = $_
            write-host "ERROR: $errorcode"
        }       
    }

Stop-Transcript
```