---
title: "Yubikey SmartCard Slot Problem"
date: 2024-10-23T07:17:00+02:00
tags: ["Yubikey","Smartcards","Administration"]
draft: false
---
Vor ein paar Jahren sind wir in der Firma auf Yubikeys gewechselt und sind vor allem auch ganz angetan von der Policy, dass sich ein Windows-Client sperrt wenn ein User den Key herauszieht. Das PKI-Management zu den Smartcards ist so eher meh, aber ich will euch hier kurz ein Problem beschreiben, welches der Verwendung von Yubikey als Smartcard unter Windows inne wohnt:

Der Yubikey hat 4 Slots. Einer davon, Slot 9a, ist für die SC Authentifizierung vorgesehen. Nun haben wir die Smartcards schon einige Jahre im Einsatz und das Certificate Renewal steht bei einigen Usern an. Und hier kommt das Problem: Ist das Certificate in 9a abgelaufen (oder droht abzulaufen), so fordert der User ein neues an, gibt seine PIN ein, Registrierung erfolgreich - aber kann sich dennoch nicht einloggen. Warum?

Das Certificate kann nicht in Slot 9a überschrieben werden.

Ich hab mal beim Support nachgefragt und das ist tatsächlich so auch nicht möglich. User sollten vor dem Renewal das Certificate auf 9a von Hand löschen und dann ein neues Cert beantragen. Das ist ein derber Fallstrick.

Da bleibe ich mal ein wenig am Ball und sehe was man da noch tun kann.

Ansonsten müsste ich meine Leitung davon überzeugen auf Windows Hello for Business und FIDO2 umzusatteln. Dann fehlt aber ihre geliebte SC Removal Policy.
