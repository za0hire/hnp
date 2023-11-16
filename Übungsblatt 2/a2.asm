        org 100h
        cpu 8086

        jmp START

		CHARS:    db 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f, 0x77, 0x7c, 0x58, 0x5e, 0x79, 0x71 ; Zeichen von 1,2,-,f

START:	in al, 00h ; Eingabe von Schalter in al schreiben
		mov bl, al ; Zwischenspeichern
		and bl, 0x0f ; Unteres Nibble Filtern
		mov cl, 4 ; Speichern von 4 Nibble
		shr ax, cl ; Verschieben um ein Nibble
		sub al, bl ; Ergebnis von ax - bx steht in ax

		out 00h, al ; Ausgabe des Ergebnis an LEDs

		mov bx, ax ; Ergebnis Zwischenspeichern
		and ax, 0x0f ; Unteres Nibble Filtern
		push ax ; Zahl auf Stack ablegen

		mov ax, bx ; Ergebnis wiederholen
		shr ax, cl ; Verschieben um ein Nibble
		push ax ; Zahl auf Stack ablegen


		pop ax ; Letzte Ziffer vom Stack holen
		mov bx, CHARS ; Staradressen von CHARS
		add bx, ax
		mov al, [bx] ; 7-Segment Zeichen in al
		out 92h, al ; Ausgabe der Ziffer ans 7-SEG Display

		pop ax ; Letzte Ziffer vom Stack holen
		mov bx, CHARS ; Staradressen von CHARS
		add bx, ax
		mov al, [bx] ; 7-Segment Zeichen in al
		out 90h, al ; Ausgabe der Ziffer ans 7-SEG Display


		JMP START
