        org 100h
        cpu 8086

        jmp START

START: in al, 00h
	out 00h, al
	out 90h, al
	JMP START

