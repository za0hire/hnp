#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void memdump (unsigned char *, int);
int findstring (char **, char *);


void memdump (unsigned char *address, int charlength) {
	printf("\nAddress\t\t%p\n", address);
	unsigned long start = (unsigned long) address;
	int diff = start%16;
	start -= diff; 
	address = (unsigned char*) start; 
	printf("ADDR\t\t0123456789ABCDEF");
	

	for (int i=0; i< (charlength+diff) || (i%16 != 0); i++) {
		if (i%16 == 0) {
			printf("\n%p\t", address);
		}
		
		if (*address < ' ' || *address > 126) {
			printf(".");	
		} else {
			printf("%c", *address);
		}		
		address++;
	}

	printf("\n\n");
}


int findstring (char **input, char *search) {

	int count = 0;
	char* vorletzter = NULL;
	char* found = NULL;	
	while (strstr(*input, search))  {
		vorletzter=found;		
		*input = strstr(*input, search);
		found = *input;
		if(found != NULL)
		{
			(*input)++;
		}
		count++;
	}
	*input = vorletzter;
	return count;
}


int main (int argc, char **argv) {
	if (argc != 3) {
		printf("Falsche Anzahl an Parameter!\n");
		return -1;
	} 

	int charlength = strlen(argv[1])+1;
	char *input = malloc(charlength);
	char *freeme = input;
	if (input) {
		strcpy(input, argv[1]);

		printf("Laenge der Zeichenkette: %i\n", charlength);
		printf("Suchkriterium: '%s'\n", argv[2]);	
		memdump((unsigned char*)input, charlength);
		
		if (argv[2] && strlen(argv[2])>0) {
		int numberOfElements = findstring(&input, argv[2]);
		printf("Die gesuchte Zeichenkette wurde %i mal gefunden.(vorletzte Adresse %p)\n", numberOfElements, input);	
		} else {
			printf("Es wurde kein Suchkriterium gegeben.\n");
		}
		free(freeme);
	}

	return 0;
}
