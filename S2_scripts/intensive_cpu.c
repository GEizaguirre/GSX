/*********************************************************************** 
# Nombre: intensive_cpu.c
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 13-05-2019 V 1.6
# 
# Descripción:
# Programa en C que trata de hacer un uso intensivo del porcesador.
#
************************************************************************/

#include <stdio.h>
#include <math.h>
 
int main(){
	int i = 0;
	long double sum = 0;
	for (i = 1; i < 10000000000; i++){
		sum = sum + i;
	}

	return 0;
}

