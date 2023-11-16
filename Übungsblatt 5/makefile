a5.out: a5.o performaddsub.o 
	gcc -m32 -g -Wall -Wextra -pedantic -o a5.out a5.o performaddsub.o

a5.o: a5.c
	gcc -m32 -g -Wall -Wextra -pedantic -c -o a5.o a5.c

performaddsub.o: performaddsub.asm
	nasm -f elf -Wall -g -o performaddsub.o performaddsub.asm

cleanup:
	rm -r "../.o"~
