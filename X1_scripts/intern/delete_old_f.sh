#! /bin/bash
# 
# delete_old_f.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 23-03-2019 Verisón 1.0
#
# Descripción:
#  Script para ejecutar tras la rotación de rsyslog en /var/log/remots.
#  Elimina los ficheros con edad superior a medio año.

echo " Executing logrotate auxiliary script."
files_to_delete=$(find /var/log/remots -mtime 182)
for file in $files_to_delete
do
	if [ -f $file ]; then
		echo " $file will be removed."
		rm $file
	fi
done

exit 0
