#! /bin/bash

# Nombre: gpgp.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 6-02-2019 V 1.0
# 
# Descripción:
# Recibe como parámetro un fichero con una lista de paths absolutos
# y devuelve los permisos de cada uno en sistema octal, el grupo y 
# el usuario.
#
# Argumentos:
# 1. Fichero con lista de paths absolutos.
# 
# Devuelve:
# Lista de los paths absolutos seguidos de los permisos, el grupo y
# el usuario.
# 
# Opciones:
# -h	Devuelve una descripción del script.
#
# Decisiones de diseño:
# Utiliza la comanda comanda stat para obtener los datos que cada 
# directorio.
#

function show_help {
	echo"
	Nombre: gpgp.sh
 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 6-02-2019 V 1.0
 
 Descripción:
 Recibe como parámetro una lista de paths absolutos y devuelve los
 permisos de cada uno en sistema octal, el grupo y el usuario.

 Argumentos:
 1. Fichero con lista de paths absolutos.
 
 Devuelve:
 Lista de los paths absolutos seguidos de los permisos, el grupo y
 el usuario.
 
 Opciones:
 -h	Devuelve una descripción del script.
"
}

# Comprobar número de argumentos.
if [ $# -ne 1 ]; then
	echo " Número de argumentos incorrecto:
	Necesario:
	1 . Fichero con paths absolutos de las direcciones a analizar. " >&2
	exit 1
fi

# Opción de mostrar ayuda.
if [ "$1" = "-h" ]; then
	show_help
	exit 0;
fi

# Comprobar si existe el fichero de entrada.
if ! [[ -f "$1" ]]; then
	echo " El fichero $1 no existe. "
	exit 1
fi

# Imprimir la información dirección a dirección.
for line in $(cat $1)
do
	# Comprobar si la dirección existe.
	if [ -d $line ] || [ -f $line ]; then 
		# La información se imprime en formato permisos-grupo-usuario.
		info="$(stat -c "%a %G %U" $line)"
		echo $line $info
	fi
done

exit 0


