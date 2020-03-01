#! /bin/bash

# Nombre: syslog_config_server.sh
# Autores: Grupo 1E
#	Bernat Boscá, Albert Canellas, Germant Telmo Eizaguirre
# 
# Configura el syslog en el servidor.

PATH="$PATH:/home/milax"
source def_interficies.sh


function show_help {
	echo "
	Configura syslog en el servidor.
	"
}

if [ "$1" = "-h" ];then
	show_help
	exit 0;
fi

echo " Se instalará el servicio rsyslog de no estar instalado."
dpkg -s rsyslog > /var/null 
test $? -eq 1 && apt install rsyslog

# Comprobamos que se ejecuta en modo superusuario.
if [ "$EUID" -ne 0 ]; then
	echo "Acceso denegado: el script debe ejecutarse en modo superusuario." >&2
	exit 1
fi

# Obtenemos la IP de la NIC y la máscarea de red.
ip_dir=$(ip addr show $IFCLI | grep "inet " | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)
ip_mask=$(ip addr show $IFCLI | grep "inet " | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 2)

# Añadimos el fichero 10-remot.conf para guardar los mensajes de los 
# clientes clasificados por fecha.
# Realizamos la copia interactivamente para que, en el caso de que
# ya exista un fichero de 10-remot.conf en /etc/rsyslog.d, el 
# administrador decida si sobreescribirlo o no.
if [ -f "intern/copia_10-remot.conf" ]; then
	cp -i intern/copia_10-remot.conf /etc/rsyslog.d/10-remot.conf
else
	echo "No se encontró el fichero necesario copia_10-remot.conf.
	Abortando configuración." >&2
	exit 1
fi


# Activamos las líneas de /etc/rsyslog.conf para escuchar udp puerto 514
sed -i '/^#.*imudp/s/^#//' /etc/rsyslog.conf

service rsyslog restart

# Configuramos el mecanismo de rotación en /etc/logrotate.conf
cp intern/copia_config_logrotate /etc/logrotate.d/remots

exit 0
