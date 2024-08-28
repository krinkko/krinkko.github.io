---
title: "HP Image Assistant Commandline Mit Powershell"
date: 2024-08-28T11:24:30+02:00
tags: ["Powershell"]
draft: false
---
Nachdem ich mich nun den Vormittag mit der an sich tollen Idee der Remoteausführung von [HP Image Assistant](https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HPIA.html) via Powershell auseinandergesetzt habe, hier mal meine 2ct dazu.

Ich hatte vor ein Script zu machen, welches mir erst einmal ausliest welche Treiber und Programme für ein bestimmtes Gerät verfügbar sind und welche Windows Update vielleicht nicht gesehen hat. Es gibt danach eine .html-Datei aus, in der die fehlenden oder aktualisierbaren Komponenten aufgelistet werden.

```powershell
# Prüfe erst mal den UNC-Pfad zum Installer
if (Test-Path -Path "\\MEINPFAD\HP\hp-hpia-5.2.1.exe") {
    #Entpacke HPIA nach C:\
    Start-Process "\\MEINPFAD\HP\hp-hpia-5.2.1.exe" -ArgumentList "/s /e /f `"C:\HPIA\HP Image Assistant`"" -wait

    # Prüfe mal, ob ein LOG-Verzeichnis bereits vorliegt auf einem UNC-Pfad
    if (-not (Test-Path -Path "\\MEINPFAD\Logs\HPIA\$($env:COMPUTERNAME)\")) {
        # Wenn kein Logverzeichnis da ist, erschaffe eins
        new-item -Path "\\MEINPFAD\Logs\HPIA\$env:COMPUTERNAME\" -ItemType Directory
        }

    # Führe HPIA im Anaylsemodus aus und erstelle ein Logfile im angegebenen Ordner
    & "C:\HPIA\HP Image Assistant\HPImageAssistant.exe" /Silent /Operation`:Analyze /Action`:List /reportfolder`:"\\MEINPFAD\Logs\HPIA\$($env:computername)\"
}
```

Wie man sieht musste ich via Powershell in den Argumenten von HPImageAssistant.exe dann die Doppelpunkte escapen. Dies ging leider auch nur so, da die EXE unter der Nutzung von <code>Start-Process</code> ebenfalls einen Frameworkfehler geworfen hat.

<b>Update 28.08.2024:</b> Da der Spaß mit Analyze nun funktioniert, wäre es natürlich noch an der Zeit einige Scriptparameter hinzuzufügen, die uns im Anschluss eine Installation der Treiber ermöglichen. Stay tuned...