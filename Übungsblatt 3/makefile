a5.out: a5.0 perform_addsub.o 
	gcc -m32 -g -Wall -Wextra -pedantic -o a5.out a5.o perform_addsub.o

a5.o: a5.c
	gcc -m32 -g -Wall -Wextra -pedantic -c -0 a5.o a5.c

perform_addsub.o: perform_addsub.asm
	nasm -f elf -Wall -g -o perform_addsub.o perform_addsub.asm

cleanup:
	rm -r "../.o"