#! /bin/bash
#
# config_router.sh
# 
# Autores: Bernat Boscá, Albert Canellas y German Telmo Eizaguirre
#
# Requerimientos:
#	Debe encontrarse el archivo def_interficies.sh en el directorio 
#	de ejecución. Debe contener los nombres y las direcciones MAC de 
#	las interficies del router. Puede escribirse manualmente o 
#	mediante el script prepara_cables_fisics_py3.py.

PATH="$PATH:/home/milax"

function show_help {
	echo " Script principal de configuración del router. "
}

# Comprobamos que se esté ejecutando en modo root
if [ $EUID -ne 0 ]; then
	echo " El script debe ejecutarse en modo root." >&2
	exit 1
fi

# Activar opción de ayuda.
test $# -eq 1 && test "$1" == "-h" && (show_help; exit 0)

# Borrar información del resto de máquinas de la red.
#sed -i '/MacServer\|MacIntern\|altres maquines/d' def_interficies.sh

source def_interficies.sh

#ifdown $IFISP
#ifdown $IFDMZ
#ifdown $IFINT

echo -e "auto\tlo
iface\tlo\tinet\tloopback\n
auto\t$IFISP
iface\t$IFISP\tinet\tdhcp\n
auto\t$IFDMZ
iface\t$IFDMZ\tinet\tstatic
\taddress\t198.18.14.17
\tnetwork\t198.18.14.16
\tnetmask\t255.255.255.240
\tbroadcast\t198.18.14.31\n
auto\t$IFINT
iface\t$IFINT\tinet\tstatic
\taddress\t172.16.4.1
\tnetwork\t172.16.4.0
\tnetmask\t255.255.255
\tbroadcast\t172.16.4.255
" > /etc/network/interfaces

# Activar forwarding.
sysctl -w net.ipv4.ip_forward=1

service procps restart

ifup $IFISP
ifup $IFDMZ
ifup $IFINT

echo " Información actual de interfaces: "
cat def_interficies.sh

bin/obtenir_macs_amb_ping6.sh

while [ $? -ne 1 ]; do
	echo " Esperando 5 seg para relanzar el análisis de direcciones MAC."
	sleep 5 # La primera ejecución a veces no funciona.
	sed -i '/MacServer\|MacIntern\|altres maquines/d' def_interficies.sh
	bin/obtenir_macs_amb_ping6.sh
done

# Por claridad eliminamos líneas en blanco.
sed -i '/^$/d' def_interficies.sh
source def_interficies.sh

echo " Se instalará el paquete isc-dhcp-server si no está instalado."
dpkg -s isc-dhcp-server > /var/null
test $? -eq 1 && apt-get -y install isc-dhcp-server

# Configuramos dhcpd.conf.
cp -p router/base_dhcpd.conf router/dhcpd.conf.tmp
sed -i "s/xMACSERVERx/$MacServer/g" router/dhcpd.conf.tmp> /var/null
sed -i "s/xMACCLIENTx/$MacIntern/g" router/dhcpd.conf.tmp> /var/null
cp router/dhcpd.conf.tmp /etc/dhcp/dhcpd.conf && rm router/dhcpd.conf.tmp

# Añadimos interfaces de escucha de DISCOVER.
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$IFDMZ $IFINT\"/g" /etc/default/isc-dhcp-server

# Reiniciamos servicio dhcp
systemctl enable isc-dhcp-server.service
systemctl start isc-dhcp-server.service

# Configuración del servidor DNS
# Instalar los paquetes bind9, bin9-doc y dnsutils
router/install_dns_packages.sh
# Ubicar los ficheros necesarios y configurar 
#/named.conf/local
router/copiar_fitxers_dns.sh
# Configurar las opciones globales de DNS
router/mod_global_options.sh
# Reiniciar el servicio como daemon
/etc/init.d/bind9 restart

# Instalamos el servidor openssj.
bin/instala_ssh.sh

# Configuramos el cortafuegos.
router/iptables_config.sh

exit 0
