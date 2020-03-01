#! /bin/bash
# preparar_lp.sh
#
# Autores: Bernat Boscá, German Telmo Eizaguirre, Albert Canellas
# 9-05-2019 Versión 1.0
#
#
# Descripción:
# Script que prepara la substitucion del comando lp.
# Crea /usr/local/secret, /usr/local/lp sino esta creado.
# Copia el script del comando lp subsituyendo el original.
# Introduce nuevos usuarios de manera encriptada al sistema /usr/local/secret.
#
# Argumentos:
# No hay
#
# Opciones:
# -h  Devuelve una descripción del script.
#
#

#Variable path de lp
PATHlp=/usr/local/lp
PATHactual=pwd
#Llave maestra
passwd=GsX2O19
PATHsecret=/usr/local/secret

#Comprobaciones iniciales.
if [ $EUID -ne 0 ]; then
	echo "canviausers.sh debe ejecutarse en modo root." >&2
	exit 1
elif [ "$1" = "-h" ]; then
	echo -e "Reemplaza la comanda lp y registra usuarios"
	exit 0
fi



#Si no existe el fichero secret se crea
if [ ! -f "$PATHsecret" ]; then
	touch $PATHsecret
fi

#Si no existe el fichero lp se crea
if [ ! -d "/usr/local/lp" ]; then
	mkdir /usr/local/lp
fi

#Si el PATHlp no se encuentra en la primera posición de PATH se añade
if [ $(echo $PATH | cut -d ':' -f1) != $PATHlp ]
then
	echo "HOLI"
	export PATH="$PATHlp:$PATH" 
	echo -e "\nexport PATH=$PATH" >> /etc/bash.bashrc
fi

#Copiamos el fichero a PATHlp
cp lp $PATHlp

newusuarios=""


echo "Introduce el usuario i las passwords"
while true; do
	read -p "Introduce el usuario: " user
	read -p "Introduce el password: " pass
	read -p "Quieres introducir mas usuarios? (y/n)" yn
	newusuarios=$(echo -e "$newusuarios\n$user;$pass")
	if [ $yn != "y" -a $yn != "Y" ]; then
		echo "Finalizando"
		break
	fi
done

echo -e "$newusuarios" >> secret.decrypt
more secret.decrypt | openssl enc -aes-128-cbc -a -salt -pass pass:$passwd > $PATHsecret
rm secret.decrypt


exit 0
