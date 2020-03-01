#! /bin/bash

# Nombre: aif

# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

# Versión: 1.0
# Data última versión: 28-02-2019 

# Descripción: Este script configura una nueva interfície de red, añadiendo 
# información al fichero $path. Se hace mediante llamadas a la funciones 'echo'
# y '>>'.
# Necesario ser superusuario para ejecutar.

# Argumentos:
# 1	Nombre de la interfície
# 2	Dirección IP
# 3	Máscara de red
# 4	Dirección de red
# 5	Puerta de enlace (Gateway)

path=/etc/network/interfaces

function show_help {
	echo "
 Nombre: aif

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 Versión: 1.0
 Data última versión: 28-02-2019 

 Descripción: Este script configura una nueva interfície de red, añadiendo 
 información al fichero $path. Necesario ser superusuario para ejecutar.

 Argumentos:
 1	Nombre de la interfície
 2	Dirección IP
 3	Máscara de red
 4	Dirección de red
 5	Puerta de enlace (Gateway)

 Opciones:
 -h	Devuelve una descripción del uso del script
"
}

#comprobar si es superusuario
if [ "$EUID" -ne 0 ]; then
	echo " Acceso denegado: el script debe ejecutarse en modo superusuario.
	"
	exit 1
fi

#comprobar que se pasan argumentos 
if [ $# -lt 1 ]; then
	echo "Este script requiere argumentos. Mostrando la ayuda 
para ver los argumentos necesarios:"
	show_help
	exit 1
fi

#comprobar llamada a la funcion help
if [ $1 = "-h" ]; then
	show_help
	exit 0
fi

#comprobar si se tienen todos los argumentos requeridos
if [ $# -lt 5 ]; then
	echo "No se han pasado todos los argumentos. Mostrando la ayuda 
para ver los argumentos necesarios:"
	show_help
	exit 1
fi

#ejecutar el echo en el fichero de interficies
echo -e "auto $1\niface $1 inet static\n\taddress $2\n\tnetmask $3\n\tnetwork $4\n\tgateway $5" >> $path
exit 0
