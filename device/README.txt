Basiert auf ../USBDemo

Pin Layout:
Benutzt: 1 MCLR, 8 Vss, 9 OSC1, 10 OSC2, 14 V(USB), 15 D-, 16 D+, 19 Vss,
        20 Vdd
Mit ICSP: 27 PGC, 28 PGD

Frei:
2 RA0
3 RA1
4 RA2
5 RA3
6 RA4
7 RA5

11 RC0
12 RC1
13 RC2

17 RC6
18 RC7

21 RB0
22 RB1
23 RB2
24 RB3
25 RB4
26 RB5
27 RB6
28 RB7

Benutzt für LEDs:
21 RB0 rot
22 RB1 gelb
23 RB2 grün
24 RB3 blau
25 RB4 weiß

Report mit 5 bytes, 1: Rot, 2: Gelb, 3: Grün, 4: Blau, 5: Weiß
Verwende jeweils Bit 0 um die entsprechende LED zu schalten.

PID: 0xFF0C

TODO:
* auf self powered umstellen/2. Konfiguration erstellen
