/*********************************************************************** 
# Nombre: intensive_mem.c
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 13-05-2019 V 1.4
# 
# Descripción:
# Programa en C que trata de hacer un uso intensivo de la memoria.
#
************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <unistd.h>

int main(){
	for(int i=0;i<10;i++){
		void *punter = malloc(1024*1024*300);		/*Reserva de 300MB de memoria para el puntero*/
		if (punter  != NULL) {				/*Si punter=NULL es que se ha producido un error al asignar el espacio de memoria*/
			memset(punter,1, 1024*1024*300);	/*Escritura del caracter '1' en 300MB a partir de la posición de mem del puntero*/
			sleep(1);				/*Retardo de 1miliseg*/
		}
	}
	
	return 0;
}
