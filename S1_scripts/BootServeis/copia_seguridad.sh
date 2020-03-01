#!/bin/bash

# Nombre: copia_seguridad.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 3-3-2019 V 1.0
#
# Efectúa una copia de seguridad de todos los ficheros modificados
# desde el último boor. Guarda la copia en formato .tgz en el directorio
# /back/aammddhhmm (referente a la fecha de la copia).
# No repite la copia si detecta una copia realizada el mismo
# día.
#
# Opciones:
# -h	Devuelve una descripción del uso del script
# 
# Decisiones de diseño:
# - Por practicidad, realizamos la copia de seguridad del directorio
#  /usr. Para realizar la copia de seguridad de todo el sistema 
#  se debe cambiar el path de origen de la comanda find a la raíz.
# - Como referencia del boot seleccionamos el fichero más antiguo de
#  del directorio de gestión de procesos /proc.

# función para mostrar ayuda sobre el script

function show_help {
	echo "
 Nombre: copia_seguridad.sh

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 	3-3-2019 V 1.0

 Efectúa una copia de seguridad de todos los ficheros modificados
 desde el último boor. Guarda la copia en formato .tgz en el directorio
 /back/aammddhhmm (referente a la fecha de la copia).
 No repite la copia si detecta una copia realizada el mismo
 día.

 Opciones:

 -h	Devuelve una descripción del uso del script

"
}

echo " Comenzando copia de seguridad"

# comprobamos los parámetros de entrada y las opciones del script

if [ "$1" = "-h" ]; then
	show_help
	exit 0
fi

# Comprobamos que el usuario se esté ejecutando en modo superusuario
# leyendo el ID del usuario efectivo del script.
if [ "$EUID" -ne 0 ]; then
	echo " Acceso denegado: el script debe ejecutarse en modo superusuario. "
	exit 1
fi

if [ $# -ne 0 ]; then
	echo " El script copia_seguridad.sh no recibe argumentos. "
	exit 1
fi 

# Comprobamos que en el directorio /admin se encuentre el script gpgp.sh
# y que sea ejecutable por root.
# Asumimos que el script gpgp.sh ejecutable será correcto.
if [[ -n $(find /usr/bin/gpgp.sh ) ]]; then
	info=$( stat -c %A /usr/bin/gpgp.sh)
	if ! [[ $info =~ ...x.* ]]; then
		echo " La dependencia ./gpgp.sh no es ejecutable. "
		exit 1
	fi
else
	echo " No se encuentró la dependencia /usr/bin/gpgp.sh. "
	exit 1
fi

# Obtenemos el nombre del directorio de backup, que será su fecha y hora de 
# generación, formatando la salida de la comanda date. 
dir_name=$(date '+%y%m%d%H%M')
# Obtenemos el día de generación para saber si se han hecho copias de seguridad
# ese mismo día.
date_ymd=$(echo $dir_name | cut -c1-6)

# Comprobamos si existe el directorio /back que guarda los backups y si se ha realizado
# una copia de seguridad ese mismo día.
if ! [[ -d /back ]]; then
	mkdir /back
fi

if [[ -n $(find /back -regex ".*/${date_ymd}.*") ]]; then
	echo " Ya se ha realizado una copia de seguridad durante 
 el día de hoy."
 # El fin de ejecución porque ya existe una copia de seguridad del día no se considera
 # erroe, por lo que el programa devuelve 0.
	exit 0
fi 

mkdir /back/$dir_name
touch /back/$dir_name/ficheros_modificados.txt

# Para encontrar todos los ficheros modificados tras el boot utilizamos
# como referencia el fichero con fecha de modificación más antigua 
# del directorio de procesos /proc
oldest_file=$(find /proc -type f -printf '%p\n' | sort | head -n 1)

# Utilizamos la comanda find y comparamos todos los ficheros con la fecha
# de modificación del fichero seleccionado.
find /usr -type f -newermm $oldest_file -print | while read line ;
do
	# Descartamos los ficheros swap.
	if [[ ! "$line" =~ .*swp ]]; then
		# Excluimos el fichero recién creado de ficheros modificados, que se guardará
		# en el archivo de backup.
		if ! [[ "$line" = "/back/$dir_name/ficheros_modificados.txt" ]]; then
			file_name=$(echo $line | rev | cut -d '/' -f 1 | rev)
			# Guardamos el fichero en la lista de ficheros modificados y 
			# realizamos una copia en la carpeta de backup.
			echo $line >> /back/$dir_name/ficheros_modificados.txt
			cp $line /back/$dir_name/$file_name
		fi
	fi
done

# Ejecutamos el script gpgp.sh para guardar ficheros, permisos, usuario y grupo en 
# permisos_save.txt.
/usr/bin/gpgp.sh /back/$dir_name/ficheros_modificados.txt > /back/$dir_name/permisos_save.txt

# Generamos el archivo comprimido con todos los datos con la comanda tar.
cd /back/$dir_name
tar -cf $dir_name.tgz *

# Eliminamos las copias de los archivos incluidos en el archivo comprimido.
while read line; do
	file_name=$(echo $line | rev | cut -d '/' -f 1 | rev)
	rm /back/$dir_name/$file_name
done < /back/$dir_name/ficheros_modificados.txt

rm /back/$dir_name/ficheros_modificados.txt
rm /back/$dir_name/permisos_save.txt

exit 0

 










