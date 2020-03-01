#! /bin/bash

# Nombre: restaurar

# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

# Versión: 4.0
# Data última versión: 03-03-2019 

# Descripción: Este script crea un servicio que cuando se enciende el sistema 
# permite restaurar los ficheros que se han guardado previamente con un 'backup'.
# Utiliza el formato system V.

# Tareas que hace el script:
# 1 entra en /back (mira si existe la carpeta)
# 2 mirar ultima fecha /back/aammddhhmm
# 3 descomprimir
# 4 copiar ficheros en el path absoluto (ficheros_modificados.txt)
# 5 restaurar propietario, grupo i permisos (permisos_save.txt)
# 6 eliminar carpeta descomprimida temporal 

if [ -d /back ]; then						# Comprobar si existe directorio /back
	if [ $(ls -l /back | wc -l) -gt 1 ]; then		# Comprobar si hay algun backup		
		dir=$(ls -t /back/ | sed -n '1p')		# ls -t (ls en orden de modificacion) sed -n '1p' (elimina espacios y coge 1era colum)
		dir=${dir%.tgz}					# Quitar la extension
		tar -C /back/ -xvf /back/$dir.tgz			# Descomprimir en el directorio	/back
		cat /back/$dir/permisos_save.txt | while read path permisos prop grupo
		do
			cp /back/$dir/$(basename $path) $(dirname $path)	# Restaurar fichero
			chmod $permisos $path					# Restaurar permisos
			chgrp $grupo $path					# Restaurar grupo
			chown $prop $path					# Restaurar propietario
		done
		cd ..
		rm -rf /back/$dir					# Eliminar directorio con los archivos descomprimidos
		exit 0
	else
		echo "ERROR, no hay nungun backup."
		exit 1
	fi
else
	echo "ERROR, no existe el directorio '/back'."
	exit 1
fi
