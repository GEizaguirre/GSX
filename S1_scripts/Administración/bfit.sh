#! /bin/bash

# Nombre: bfit
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 28-02-2019 V 1.0
# Mediante el uso de este script se vacia el contenido de un fichero
# pasado por parametro. Esto se hace con la ayuda de la funcion truncate
# que limita el tamaño del fichero.
# Argumentos:
# 1-	Path absoluto del fichero
# Opciones:
# -h	Devuelve una descripción del uso del script
                       
#funcion del help
function show_help {
	echo "
 Nombre: bfit

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 	28-02-2019 V 1.0

 Vacia el contenido de un fichero pasado por parametro.

 Argumentos:
 1	Path absoluto del fichero

 Opciones:
 -h	Devuelve una descripción del uso del script
"
}

#comprobacion de llamada al help
if [ "$1" = "-h" ]; then
	show_help
	exit 0
fi

#si se pasan correctamente los parametros eliminar contenido con truncate
if [ $# -lt 1 ]; then
	echo "No se han passado el numero correcto de parametros. Mostrando la ayuda:"
	show_help
	exit 1
#comprobar que el path es correcto
elif [ -e $1 ]; then
	truncate -s 0 $1
	exit 0
else
	echo "El path no es correcto. Mostrando la ayuda:"
	show_help
	exit 1	
fi
