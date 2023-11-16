	;Frequenz wird richtig ausgegeben!!!	


		org 100h
		cpu 8086

		jmp start

; Variablen

status	db 00000000b	; Statusbyte
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

start:

; Initialisierung

	mov ah, clrscr		; Anzeige aus
	int conout
	
	mov byte [status], 0	; Init. Statusbyte und alle LEDs
	mov al, 0
	out ppi_a, al
	out leds, al

	mov byte [status], 0
	call init			; Controller und Interruptsystem scharfmachen

; Hintergrundprogramm (ist immer aktiv, wenn im Service nichts zu tun ist)
; Hier sollten Ausgaben auf das Display getätigt werden, Tastatureingaben, etc.

again:

; Code des Hintergrundprogammes	
	mov al, bl 	; Low-Teil Zeitkonstante
	out pit1, al	
	mov al, bh	; High-Teil Zeitkonstante
	out pit1, al
		
	;prüfe, ob taste gedrückt:
	xor ax, ax ;alte Werte löschen
	xor bx, bx ;alte Werte löschen
	in al, keybd
	out 0, al
	mov cl, 5 ;Zeilen von Spalten trennen
	shl ax, cl
	shr al, cl
	and al, 7
	cmp al, nokey ;prüfen ob in einer Zeile eine Taste gedrückt ist
	je nokeypress
	

	mov cl, 1	
	shr al, cl ;zeilen sind nun 1,2 oder 3
	sub al, 1; zeilen sind jetzt 0,1,2

	;zeile * 8 +spalte
	mov cl,3
	shl al, cl
	add al, ah ;offset in tonhöheArray ausrechnen
	mov cl, 1 ;verdoppeln weil Word nicht Byte
	xor ah, ah
	shl al, cl
	
	;Displayausgabe:
	mov bx, tonleiterText
	add bx, ax
	mov bx, [bx]
	push ax
	mov ah, 2
	mov dl, 7
	int 6
	pop ax
	
	;tonhöhe nachschlagen
	mov bx, tonleiter
	add bx, ax
	mov bx, [bx];f steht jetzt in bx
	add bx, bx; f*2
	
	;vorteiler ausrechenen
	mov dx, basefreq >> 16
	mov ax, basefreq & 0ffffh;?
	div bx
	mov bx, ax
	
	or byte [status], 1

	jmp again
nokeypress:
	and byte [status], ~1
	mov ah, 0
	int 6
	jmp again

		
; Initialisierung Controller und Interruptsystem

init:
	cli			; Interrupts aus

; PIT-Init.

;	Nichts zu tun, das macht die Main-Loop :-)
	mov al, 01110110b	; Kanal 1, Mode 3, 16-Bit ZK
	out pitc, al		; Steuerkanal
;	mov al, tcfreq & 0ffh	; Low-Teil Zeitkonstante
;	out pit1, al
;	mov al, tcfreq >> 8	; High-Teil Zeitkonstante
;	out pit1, al

; PPI-Init.
	mov al, 10001011b	; PPI A/B/C Mode 0, A Output, sonst Input
	out ppi_ctl, al
	jmp short $+2		; I/O-Delay
	mov al, 0			; LED's aus (high aktiv)
	out ppi_a, al
	
; PIC-Init.
	mov al, 00010011b	; ICW1, ICW4 benoetigt, Bit 2 egal, 
						; Flankentriggerung
	out icw_1, al
	jmp short $+2		; I/O-Delay
	mov al, 00001000b	; ICW2, auf INT 8 gemapped
	out icw_2_4, al
	jmp short $+2		; I/O-Delay
	mov al, 00010001b	; ICW4, MCS-86, EOI, non-buffered,
				; fully nested
	out icw_2_4, al
	jmp short $+2		; I/O-Delay
	mov al, 11111110b	; Kanal 0, 1 + 7 am PIC demaskieren
						; PIT K1
	out ocw_1, al
	
; Interrupttabelle init.	
	
	mov word [intab0], isr_freqtimer	; Interrupttabelle (Timer K1) 
						; initialisieren (Offset)
	mov [intab0 + 2], cs		; (Segmentadresse)
	
	sti					; ab jetzt Interrupts
	ret

;------------------------ Serviceroutine -----------------------------------
	
isr_freqtimer: 				; Timer fuer Lautsprecher
	push ax	
	test byte [status],1
	jz isr_freqtimer_out
	in al, ppi_a;
	xor al, ppi_pa3
	out ppi_a, al
; Code der Serviceroutine fuer die Lautsprecherausgabe	
	
isr_freqtimer_out: 		; Ausgang aus dem Service
	mov al, eoi			; EOI an PIC
	out ocw_2_3, al
	pop ax
	iret

;Frequenzen in zwei Oktaven von c4 bis b5 in Hertz (Hz)

tonleiter:
	dw 262 ; c4   0
	dw 277 ; c#4  1
	dw 294 ; d4   2 
	dw 311 ; d#4  3
	dw 329 ; e4   4
	dw 349 ; f4   5
	dw 370 ; f#4  6
	dw 392 ; g4   7
	dw 415 ; g#4  8
	dw 440 ; a4   9
	dw 466 ; a#4  10
	dw 493 ; b4   11
	dw 523 ; c5   12
	dw 554 ; c#5  13 
	dw 587 ; d5   14
	dw 622 ; d#5  15
	dw 659 ; e5   16
	dw 698 ; f5   17 
	dw 740 ; f#5  18
	dw 784 ; g5   19
	dw 830 ; g#5  20
	dw 880 ; a5   21
	dw 932 ; a#5  22 
	dw 987 ; b5   23

text0: db '262',0 ; c4   0
text1: db '277',0 ; c#4  1
text2: db '294',0 ; d4   2
text3: db '311',0 ; d#4  3
text4: db '329',0 ; e4   4
text5: db '349',0 ; f4   5
text6: db '370',0 ; f#4  6
text7: db '392',0 ; g4   7
text8: db '415',0 ; g#4  8
text9: db '440',0 ; a4   9
text10: db '466',0 ; a#4  10
text11: db '493',0 ; b4   11
text12: db '523',0 ; c5   12
text13: db '554',0 ; c#5  13 
text14: db '587',0 ; d5   14
text15: db '622',0 ; d#5  15
text16: db '659',0 ; e5   16
text17: db '698',0 ; f5   17 
text18: db '740',0 ; f#5  18
text19: db '784',0 ; g5   19
text20: db '830',0 ; g#5  20
text21: db '880',0 ; a5   21
text22: db '932',0 ; a#5  22 
text23: db '987',0 ; b5   23

tonleiterText: dw text0, text1, text2, text3, text4, text5, text6, text7, text8, text9, text10, text11, text12, text13,  text14, text15, text16, text17, text18, text19, text20, text21, text22, text23
	
	
