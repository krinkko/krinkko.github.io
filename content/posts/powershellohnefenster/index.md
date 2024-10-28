---
title: "Powershellscript ohne Fenster"
date: 2022-02-17T11:17:20+01:00
tags: ["Powershell","Scripting","Scripte","vbs"]
categories: "Powershell"
---
Man kann einfach ein bisschen vbs-Code dazu benutzen um ein Powershellfenster vor Usern zu verstecken:

```cmd
Dim objArguments
Dim command
Set objArguments = WScript.Arguments
command = "powershell.exe -nologo -command " & objArguments(0) & ""
set shell = CreateObject("WScript.Shell")
shell.Run command,0
```

Speichern wir das nun z.B. als Launchpwrshl.vbs können wir direkt ein Script als Argument[0] daran hängen:

```cmd
 launchpwrshl.vbs meinscript.ps1
 ```

Nützlich, wenn man ein Powershellscript als Aufgabe oder so laufen lassen will.