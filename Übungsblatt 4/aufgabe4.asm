		org 100h
		cpu 8086

		jmp start
; Variablen

status	db 1000000b	; Statusbyte
;		          ^
;		          |
;		          +-----> Ton (1, an) / (0, aus)
; Konstanten
intab0		equ 20h		; Adresse Interrupttabelle PIT, Kanal 1
intab1		equ intab0 + 1 * 4	; Adresse Interrupttabelle PIT, Kanal 2
intab7		equ intab0 + 7 * 4	; Adresse Interrupttabelle Lichttaster
eoi			equ 20h		; End Of Interrupt (EOI)
clrscr		equ 0		; Clear Screen
getkey		equ 1		; Funktion auf Tastatureingabe warten
ascii		equ 2		; Funktion ASCII-Zeichenausgabe
hexbyte		equ 4		; HEX-Byte Ausgabe
conin		equ 5		; Console IN
conout		equ 6		; Console OUT
pitc		equ 0a6h	; Steuerkanal PIT
pit1		equ 0a2h	; Counter 1 PIT
pit2		equ 0a4h	; Counter 2 PIT
ppi_ctl		equ 0b6h	; Steuerkanal PPI (Parallelinterface)
ppi_a		equ 0b0h	; Kanal A PPI
ppi_pa0		equ 1		; LED 0
ppi_pa1		equ 2		; LED 1
ppi_pa2		equ 4		; LED 2
ppi_pa3		equ 8		; Lautsprecher
ppi_pa6		equ 1 << 6	; Servomotor
ppi_b		equ 0b2h	; Kanal B PPI
ppi_c		equ 0b4h	; Kanal C PPI
ocw_2_3		equ 0c0h	; PIC (Interruptcontroller), OCW2,3
ocw_1		equ 0c2h	; PIC (Interruptcontroller), OCW1
icw_1		equ 0c0h	; PIC (Interruptcontroller), ICW1
icw_2_4		equ 0c2h	; PIC (Interruptcontroller), ICW2,4
leds		equ 0		; LED Port
schalter	equ 0		; Schalterport
keybd		equ 80h		; SBC-86 Tastatur
gokey		equ 11h		; Taste "GO"
outkey		equ 15h		; Taste "OUT"
sseg7		equ 9eh		; Segmentanzeige 7
tcfreq		equ 440		; initiale Frequenz
basefreq	equ	1843200	; Basistakt in Hz
nokey		equ 7		; keine Taste gedrueckt


START: 
	mov byte [status], 1	; Init. Statusbyte und alle LEDs
	mov al, 1
	out ppi_a, al
	out leds, al

	JMP START
