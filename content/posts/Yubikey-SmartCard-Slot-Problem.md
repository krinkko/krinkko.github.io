---
title: "Yubikey SmartCard Slot Problem"
date: 2024-10-23T07:17:00+02:00
tags: ["Yubikey","Smartcards","Administration"]
categories: ["Sysadmin"]
description: "Yubikeys haben einige Slots. Das ist nicht immer praktisch."
draft: false
---
Vor ein paar Jahren sind wir in der Firma auf Yubikeys gewechselt und sind vor allem auch ganz angetan von der Policy, dass sich ein Windows-Client sperrt wenn ein User den Key herauszieht. Das PKI-Management zu den Smartcards ist so eher meh, aber ich will euch hier kurz ein Problem beschreiben, welches der Verwendung von Yubikey als Smartcard unter Windows inne wohnt:

Der Yubikey hat 4 Slots. Einer davon, Slot 9a, ist für die SC Authentifizierung vorgesehen. Nun haben wir die Smartcards schon einige Jahre im Einsatz und das Certificate Renewal steht bei einigen Usern an. Und hier kommt das Problem: Ist das Certificate in 9a abgelaufen (oder droht abzulaufen), so fordert der User ein neues an, gibt seine PIN ein, Registrierung erfolgreich - aber kann sich dennoch nicht einloggen. Warum?

Das Certificate kann nicht in Slot 9a überschrieben werden.

Ich hab mal beim Support nachgefragt und das ist tatsächlich so auch nicht möglich. User sollten vor dem Renewal das Certificate auf 9a von Hand löschen und dann ein neues Cert beantragen. Das ist ein derber Fallstrick.

Da bleibe ich mal ein wenig am Ball und sehe was man da noch tun kann.

Ansonsten müsste ich meine Leitung davon überzeugen auf Windows Hello for Business und FIDO2 umzusatteln. Dann fehlt aber ihre geliebte SC Removal Policy.

## Update 28.10.2024:

Der Yubico Support hatte mir nun geantwortet. Dabei einige Details zu dieser Sache und warum man sich durchaus überlegen sollte lieber FIDO2 oder sowas zu nutzen.

<blockquote>
Hi Krinkkerz,
 
Good question!
 
That is correct, slot 9A is associated with the private key used to authenticate the card and the cardholder. This slot is used for things like system login.
 
I've written some further information you may find helpful:
 
The GIDS specification that Windows uses, uses a CMAP file (container map), and the first provisioned certificate using the YubiKey Smart Card Minidriver stores the certificate in slot 9A - if you were then to plug this YubiKey into a system without the YubiKey Smart Card Minidriver installed, that certificate would still be usable in the other systems for authentication. GIDS doesn't use slots, it uses containers, and the CMAP file links to where the certificates are stored. 
 
If an ADCS template is configured to use a new key, the KSP will create a new key container, the YubiKey Smart Card Minidriver will find the next unused slot in its priority list (auth certs: 9a,9d,81,82,83...,9c,9e; signature certs: 9c,9d,81,82...,9a;9e), then the cert is loaded into the object corresponding to the new key container's slot.
 
It is not possible to specify a specific slot for the certificate at the time it is created unless you delete the previous certificate so it chooses slot 9a. 
 
According to this Microsoft article:
 
<i>The certificate propagation service activates when a signed-in user inserts a smart card in a reader that is attached to the computer. This action causes the certificate to be read from the smart card. The certificates are then added to the user's Personal store.</i>
 
The YubiKey Smart Card Minidriver will allow you to use "Use Multiple Authentication Credentials" for authentication. However, the retired slots cannot be used for authentication.

You can find additional information on PIV slots <a href="https://developers.yubico.com/PIV/Introduction/Certificate_slots.html">here</a>.
 
I know this is a lot of information, so please let me know if you have any questions after reviewing everything! Thanks!

Kind regards,
Michael
Customer Support Specialist | Yubico
</blockquote>


