#! /bin/bash
#
# inici_dhcp_v1.sh
#
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 21-03-2019 Versión 1.0
#
# Descripción:
#  Coloca los ficheros del servidor dhcp con la configuración necesaria
#  para la red de la entrega X1 de la asignatura de Gestión de Sistemas
#  y Redes.
#
# Dependencias:
#  Ya que la instalación se realiza a partir de ficheros preconfigurados,
#  se debe haber instalado previamente el paquete isc-dhcp-server.
#  Debe encontrarse el fichero def_interficies.sh en el PATH con las
#  definiciones de las interficies.

PATH="$PATH:/home/milax"

dpkg -s isc-dhcp-server > /var/null
test $? -eq 1 && (echo " El paquete isc-dhcp-server no está instalado." >&2; exit 1)

test ! -f def_interficies.sh && (echo "no se encontró el fichero def_interficies.sh." >&2; exit 1)

source def_interficies.sh

ifdown $IFISP --force
ifdown $IFDMZ --force
ifdown $IFINT --force


test -f router/interfaces && cp -p router/interfaces /etc/network/interfaces || ( echo " No se encuentra el archivo interfaces." >&2; exit 1)

test -f router/dhcpd.conf && cp -p router/dhcpd.conf /etc/dhcp/dhcpd.conf || ( echo " No se encuentra el archivo dhcpd.conf." >&2; exit 1)

test -f router/isc-dhcp-server && cp -p router/isc-dhcp-server /etc/default/isc-dhcp-server || ( echo " No se encuentra el archivo isc-dhcp-server." >&2; exit 1)

echo 1 > /proc/sys/net/ipv4/ip_forward

ifup $IFISP
ifup $IFDMZ
ifup $IFINT

service enable isc-dhcp-server.service
service start isc-dhcp-server.service

echo " Se han colocado los ficheros de configuración del servidor DHCP."


exit 0
