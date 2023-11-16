#include <stdio.h>
#include <stdlib.h>

void printflag(unsigned short);
void printsigned(short, char);
void printunsigned(unsigned short, char);

extern int performaddsub(int a, int b, char operation, unsigned short *flags); //Assembler-Routine öffnen

int main(int argc, char** argv) {
   // Überprüfen von richtiger Anzahl von Argumenten
    if (argc != 4) {
            printf("Falsche Anzahl an Parameter!\n");
            return 1;
        } 

    // Informationen holen aus argv
    int a = atoi(argv[1]);
    int b = atoi(argv[3]);
    char operation = argv[2][0];
    
   if (operation != '+' && operation != '-') {
        printf("Ungültige Operation.\n");
        return 1;
    }

    unsigned short flags;

    // Aufruf der Assembler Methode
    int result = performaddsub(a, b, operation, &flags);

    printflag(flags);
    printf("\n");

    char signedRichtig = (flags & 0x800) ? 0 : 1; // Overflow Flag gesetzt
    char unsignedRichtig = (flags & 0x1) ? 0 : 1; // Carry Flag gesetzt

    printf("Signed: %i %c %i", (short)a, operation, (short)b);
    printsigned(result, signedRichtig);
    printf("Unsigned: %i %c %i", (unsigned short) a, operation, (unsigned short)b);
    printunsigned(result, unsignedRichtig);

   
    return 0;
}

void printsigned(short result,  char signedRichtig) {
	printf(" = %i (Ergebnis ist %s)\n", result, (signedRichtig ? "richtig" : "falsch"));
}

void printunsigned(unsigned short result, char unsignedRichtig) {
	printf(" = %i (Ergebnis ist %s)\n", result, (unsignedRichtig ? "richtig" : "falsch"));
}

void printflag(unsigned short flags) {
    printf("Flags:\n");
    printf("O D I T S Z   A   P   C\n");
    for(int i = 11; i >= 0; i--)
    {
       printf("%i ", (flags >> i) &1);
    }

    printf("\n");
}
