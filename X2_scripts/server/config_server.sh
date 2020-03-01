#! /bin/bash
#
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 23-03-2019 Versión 1.0
#
# Descripción:
#  Configura el servidor de la red de la entrega X1 de la asignatura
#  de Gestión de Sistemas y Redes.
#
# Dependencias:
#  Archivo def_interficies.sh con las definiciones de las interficies
#  y las direcciones MAC.

PATH="$PATH:/home/milax"

test ! -f def_interficies.sh && (echo " No se encontró el archivo def_interficies.sh." >&2; exit 1)

source def_interficies.sh

hostnamectl set-hostname Server
sed -i 's/GSX/Server/g' /etc/hosts

ifdown $IFSER --force

echo -e "
auto\tlo
iface\tlo\tinet\tloopback\n
auto\t$IFSER
iface\t$IFSER\tinet\tdhcp
" > /etc/network/interfaces

# Configurar DNS en el cliente
#cp -p bin/hostname /etc/dhcp/dhclient-exit-hooks.d/hostname

systemctl restart networking.service

ifup $IFSER

# Configurar rsyslog en el cliente
server/rsyslog_config_client.sh

bin/instala_ssh.sh
apt-get -y install apache2

sed -i "s/It works!/GRUP 1E GSX COMPLETED?(PLEASE)/g" /var/www/html/index.html
service apache2 restart

# Configuración snmp.
snmp_config/snmp_config.sh

exit 0
