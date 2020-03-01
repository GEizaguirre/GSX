#!/bin/bash

# Nombre: reg_proc.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 1-03-2019 V 1.0
# Muestra los procesos que han acabado con una señal SIGTERM o 
# con un dump core entre las 13:00 y las 14:59 del día actual.
# 
# Decisiones de diseño:
#
# Utilizamos la comanda lastcomm, por lo que el accounting debe 
# estar activado previamente en el sistema. 


# función para mostrar ayuda sobre el script

function show_help {
	echo "
 Nombre: reg_proc.sh

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 	1-03-2019 V 1.0
  Muestra los procesos que han acabado con una señal SIGTERM o 
  con un dump core entre las 13:00 y las 14:59 del día actual.

 Opciones:
 -h	Devuelve una descripción del uso del script
"
}

# comprobamos si el usuario solicita ayuda

if [ $# -gt 1 ]; then
	echo " Número de argumentos incorrecto."
	exit 1
fi

if [ $# -eq 1 ]; then
	if [ "$1" = "-h" ]; then
		show_help
		exit 0;
	else 
		echo " Argumento incorrecto. "
		exit 1
	fi
fi

# Seleccionamos las líneas de lastcomm (lee el fichero de accounting con
# los datos de las comandas registradas) según sus flags. Seleccionamos 
# las que indican que el proceso ha acabado con core dump (D) o señal 
# SIGTERM (X).
# Imprimimos el nombre de la comanda y el usuario, ordenados por la hora
# de ejecución y que daten a fecha de hoy.
month=$(date | tr -s ' ' | cut -d ' ' -f 2)
day=$(date | tr -s ' ' | cut -d ' ' -f 3)
lastcomm | grep -e '^.* *...D. .* 1[8,9]:..$' -e '^.* *....X .* 1[8,9]:..$' -e '^.* *...DX .* 1[8,9]:..$' | grep -i "${month} *${day}" | cut -c1-17,24-32,65-69 | sort -k 3

exit 0

