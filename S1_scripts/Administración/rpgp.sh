#! /bin/bash

# Nombre: rpgp.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 
# 27-3-2019
# 
# Descripción:
# Recibe un fichero con paths absolutos, permisos, grupos y usuarios
# generado por el script gpgp.sh. Compara las direcciones con los datos
# actuales y actualiza la información contradictoria si el usuario lo confirma.
#
# Parámetros:
# 1. Fichero con lista de paths absolutos, permisos, grupo y usuario (salida de gpgp.sh).
# 
# Opciones:
# -h Devuelve una descripción del script.
#
# Decisiones de diseño:
# Asumimos que el formato del fichero de entrada es correcto y va acorde con el 
# generado por gpgp.sh.

function show_help {
	echo "
 Nombre: rpgp.sh
 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
 
 27-3-2019
 
 Descripción:
 Recibe un fichero con paths absolutos, permisos, grupos y usuarios
 generado por el script gpgp.sh. Compara las direcciones con los datos
 actuales y actualiza la información contradictoria si el usuario lo confirma.

 Parámetros:
 1. Fichero con lista de paths absolutos, permisos, grupo y usuario (salida de gpgp.sh).
 
 Opciones:
 -h Devuelve una descripción del script.
"
}
	

# Comprobamos que el script se ejecuta en superusuario
if [ "$EUID" -ne 0 ]; then
	echo " El script debe ejecutarse en modo superusuario. " >&2
	exit 1
fi

# Comprobamos que tenga un número de argumentos correcto.
if [ $# -ne 1 ]; then
	echo " Número de argumentos incorrecto:
	Necesario:
	1. Fichero de salida de gpgp.sh. " >&2
	exit 1
fi

# Opción de ayuda.
if [ "$1" = "-h" ]; then
	show_help
	exit 0
fi

# Comprobamos que exista el fichero de entrada.
if ! [ -f "$1" ]; then
	echo "$1 no existe." >&2
	exit 1
fi

# Lectura del fichero de entrada dirección a dirección.
while read direccion permisos grupo usuario; do
	# Obtener permisos, grupo y usuario de la dirección actual.
	current_perm=$(stat -c "%a" $direccion)
	current_grup=$(stat -c "%G" $direccion)
	current_user=$(stat -c "%U" $direccion)

	# Comprobar que la dirección exista.
	if [ -d $direccion ] || [ -f $direccion ]; then

		# Informar al usuario de que se realizarán cambios.
  		echo "*** $direccion" 
  		echo "Información ahora: " $current_perm $current_grup $current_user
  		echo "Información nueva: " $permisos $grupo $usuario
		# Pedir confirmación.
  		echo " ¿Quiere modificar la información de $direccion? [S/N]"

		# Leemos la entrada de usuario por un una terminal tty que no entre en conflicto con la entrada estándar
		# en este caso; el fichero.
		read option </dev/tty
		if [ "$option" == "S" ] || [ "$option" == "s" ]; then
			# Cambios pertinentes.
			if  ! [[ "$current_perm" == "$permisos" ]]; then 
				chmod $permisos $direccion
			fi
			if ! [[ "$current_grup" == "$grupo" ]]; then 
  				chgrp $grupo $direccion
			fi
			if ! [[ "$current_user" == "$user" ]]; then 
  				chown $usuario $direccion
			fi
		fi
	else
		echo "$direccion no existe."
	fi

done < $1

exit 0
