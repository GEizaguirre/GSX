#! /bin/bash
#
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 22-03-2019 Versión 1.0
#
# Descripción:
#  Configura el cliente de la red de la entrega X1 de la asignatura de 
#  Gestión de Sistemas y Redes.
#
# Dependencias: 
#  Archivo def_interficies.sh con las definiciones de las interficies
#  y las direcciones MAC.

PATH="$PATH:/home/milax"

test ! -f def_interficies.sh && (echo " No se encontró el archivo def_interficies.sh." >&2; exit 1)

source def_interficies.sh

hostnamectl set-hostname Client
sed -i 's/GSX/Client/g' /etc/hosts

ip link set $IFCLI down

echo -e "
auto\tlo
iface\tlo\tinet\tloopback\n
auto\t$IFCLI
iface\t$IFCLI\tinet\tdhcp
" > /etc/network/interfaces

# Configurar DNS en server
#cp -p bin/hostname /etc/dhcp/dhclient-exit-hooks.d/hostname 

systemctl restart networking.service

ip link set $IFCLI up

# Configurar rsyslog en el cliente de syslog (Server)
intern/rsyslog_config_server.sh

# Instalamos el servidor ssh
bin/instala_ssh.sh

# Instalar servicio snmp
snmp_config/snmp_config.sh

exit 0

