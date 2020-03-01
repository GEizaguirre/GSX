/*********************************************************************** 
# Nombre: intensive_disk.c
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 13-05-2019 V 1.2
# 
# Descripción:
# Programa en C que trata de hacer un uso intensivo del disco.
#
************************************************************************/

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

#define TAMANO_BUFFER 30600

int main (int argc, char * argv [])
{
	char bf [TAMANO_BUFFER];
	int i, j, z;
	int fl;

	fl = open ("IOIntensive.txt", O_CREAT | O_WRONLY);
	
	i = 0;
	while ( i < TAMANO_BUFFER )
	{
		bf[i++] = 'H';
		bf[i++] = 'E';
		bf[i++] = 'M';
		bf[i++] = 'V';
		bf[i++] = 'O';
		bf[i++] = 'T';
		bf[i++] = 'A';
		bf[i++] = 'T';
		bf[i++] = 'H';
		bf[i++] = 'E';
		bf[i++] = 'M';
		bf[i++] = 'G';
		bf[i++] = 'U';
		bf[i++] = 'A';
		bf[i++] = 'N';
		bf[i++] = 'Y';
		bf[i++] = 'A';
		bf[i++] = 'T';
	}
	
	i = 0;
	while ( i < TAMANO_BUFFER )
	{
		write (fl, bf, TAMANO_BUFFER);	
	}
	
	remove ("IOIntensive.txt");
	printf ("\n Fin cálculos. Tamaño resultado: %d B\n\n", (TAMANO_BUFFER*TAMANO_BUFFER));
	close(fl);
	return 0;	

}
