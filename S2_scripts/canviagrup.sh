#! /bin/bash
# canviagrup.sh
#
# Autores: Bernat Boscá, German Telmo Eizaguirre, Albert Canellas
# 9-05-2019 Versión 1.3
#


# Comprobaciones iniciales.
if [ $EUID -ne 0 ]; then
	echo " canviagrup.sh debe ejecutarse en modo root." >&2
	exit 1
fi
if [ $# -ne 1 ]; then
	echo " El número de argumentos no es correcto." >&2
	exit 1
fi
if [ "$1" = "-h" ]; then
	echo -e "Canvia el grupo del usuario pasado por parametro y genera el fichero : \n <Fecha> \n <Usuario> \n <Time>"
	exit 0
fi

#Mirar si el grupo existe 
egrep -i "^$1:" /etc/group
if [ $? -eq 0 ]; then
	echo "Canviando a grupo: $1"
else
	echo "Group does not exist -- Invalid Group name"
	exit 1
fi

#Miramos si la carpeta temps existe
if [ ! -d /root/temps ]; then
	mkdir /root/temps
fi

#Guardamos fecha
echo "Fecha: $(date)" > /root/temps/$1
#Guardamos el usuario
echo "Usuario: $(id -un)" >> /root/temps/$1
#Canviamos de grupo y guardamos el tiempo
time newgrp $1 2>> /root/temps/$1


exit 0
