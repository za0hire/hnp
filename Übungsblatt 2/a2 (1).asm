        org 100h
        cpu 8086

        jmp START

CHARS:  db 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f, 0x77, 0x7c, 0x58, 0x5e, 0x79, 0x71

START:	in al, 00h ; Eingabe von Schalter in al schreiben
	mov bx, ax ; Zwischenspeichern
	and bx, 0x0f ; Unteres Nibble Filtern
	mov cl, 4 ; Speichern von 4 Nibble
	shr ax, cl ; Verschieben um ein Nibble
	sub al, bl ; Ergebnis von ax - bx steht in ax

	out 00h, al ; Ausgabe des Ergebnis an LEDs
	
	mov bx, ax ; Ergebnis Zwischenspeichern
	and ax, 0x0f ; Unteres Nibble Filtern
	push ax ; Erste Zahl auf Stack ablegen

	mov ax, bx ; Ergebnis zurück auf ax
	shr ax, cl ; Verschieben um ein Nibble
	push ax ; Zweite Zahl auf Stack ablegen

	pop ax ; Erste Zahl vom Stack
	mov bx, CHARS ; Startadresse von Chars
	add bx, ax ; Richtige Ziffer wählen
	mov al, [bx] ; 
	out 9eh, al ; Ausgabe am 7-SEG Display

	pop ax ; Erste Zahl vom Stack
	mov bx, CHARS ; Startadresse von Chars
	add bx, ax ; Richtige Ziffer wählen
	mov al, [bx] ; 
	out 9ch, al ; Ausgabe am 7-SEG Display

	JMP START