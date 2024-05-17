---
title: "Better AutoDesk Deployment"
date: 2024-03-18T11:03:00+01:00
tags: ["Software Deployment","AutoDesk","Sysadmin"]
draft: true
---
Es ist wieder so weit für einen kleinen meinungsschwangeren Tutorialartikel zum Thema "AutoDesk für Sysadmins". Wir wissen alle, dass nach der Einführung von AutoDesk ODIS Modern Installer irgendwie alles verschlimmbessert (neuDeutsch: Enshittyfied) wurde.

Zunächst kann man bei AutoDesk im Manage Portal zwei stabile Installationsmethoden erstellen: Install oder Deployment.

<b>Install</b> bietet den Typischen installer, der zwar mit dem Parameter <i>-q</i> bedient werden kann, was sich aber nur auf den Download der Daten auswirkt. Nimmt man den Parameter also mit, so wird nur der Download abgeschlossen. Der Installer hört danach auf. Für ein Deployment also nicht so geeignet. ABER, später hierzu mehr.
