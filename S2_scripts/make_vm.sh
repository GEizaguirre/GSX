# !/bin/bash

# Nombre: make_vm.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 12-05-2019 V 1.0
# 
# Descripción:
# Monta  un disco virtual de tipo tmpfs y tamaño 100MB en /mnt/mem.
# 
# Opciones:
# -h	Devuelve una descripción del script.
#
# Decisiones de diseño:
# Comprueba si existe el directorio, si está vacío, y si ya está
# montado el disco virtual.
# Ofrece la opción de hacer el montado permanente modificando
# /etc/fstab.
#

function show_help {
	echo"
	Nombre: gpgp.sh
 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 6-02-2019 V 1.0
 
 Descripción:
 Monta  un disco virtual de tipo tmpfs y tamaño 100MB en /mnt/mem.
 
 Opciones:
 -h    Devuelve una descripción del script.

"
}

# Comprobamos que el script se haya ejecutado en root comprobando
# el ID del usuario efectivo.

if [ "$EUID" -ne 0 ]; then
	echo "Acceso denegado: el script debe ejecutarse en modo superusuario."
	exit 1
fi


# Opción de mostrar ayuda.
if [ "$1" = "-h" ]; then
	show_help
	exit 0;
fi

if [ -d /mnt/mem ]; then
	echo " El directorio /mnt/mem existe."
	[ "$(ls -A /mnt/mem)" ] && echo " El directorio /mnt/mem no está vacío. " || echo " El directorio /mnt/mem está vacío. "
	[ "$(mount | grep " /mnt/mem*")" ] && echo " Hay un SF montado en /mnt/mem."  || echo " No hay ningún SF montado en /mnt/mem."
	read -p " ¿Quieres montar el disco virtual en /mnt/mem? [y/n]" yn
    	case $yn in
        	[Yy]* ) while [ "$(mount | grep "on /mnt/mem " )" ]; do umount /mnt/mem; done;;
        	* ) exit 2;;
	esac
else
	echo " /mnt/mem no existe. Se montará el disco virtual."
	mkdir /mnt/mem
fi

mount -t tmpfs -o size=100m tmpfs /mnt/mem

read -p " ¿Quieres hacer el montado permanente? [y/n]" yn
case $yn in
                [Yy]* ) echo "tmpfs       /mem/mnt tmpfs   nodev,nosuid,nodiratime,size=100M   0 0" >> /etc/fstab;;
                * ) exit 0;;
esac
# nodiratime: no guardar el timestamp de acceso a los nodos directorio.
# nodev: que el SF no pueda contener dispositivos especiales.
# nosuid: no se permiten archivos con bit setuid activo, no habrá ejecutables
# que aumenten los privilegios de los usuarios.

echo " Finalizado."
exit 0

