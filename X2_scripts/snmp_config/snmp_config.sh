# !/bin/bash

#
# Script para configurar nuestro servicio snmp.
#

PATH="$PATH:/home/milax"

# instalamos los paquetes necesarios
apt update
apt -y install smistrip
apt -y install patch
apt -y install snmp
apt -y install snmpd

# Instalamos el descargador de MIBS.
#links http://ftp.es.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.1+nmu1_all.deb
dpkg -i /home/milax/snmp_config/snmp-mibs-downloader_1.1+nmu1_all.deb
# Descargamos los mibs
download-mibs
# Activamos los mibs descargados.
sed -i '/^mibs/d' /etc/snmp/snmp.conf
echo "mibs +ALL" >> /etc/snmp/snmp.conf
sed -i -e '1imibdirs + /usr/share/mibs\' /etc/snmp/snmp.conf

# Sustitución de un archivo de configuración para evitar el error
# Bad operator (INTEGER): At line 73 in /usr/share/snmp/mibs/ietf/SNMPv2-PDU
wget http://pastebin.com/raw.php?i=p3QyuXzZ -O /usr/share/snmp/mibs/ietf/SNMPv2-PDU
# Ahora podemos comprobar los OID de los mibs mediante 
# snmptranslate. Buscamos en un buscador externo el OID
# de cada uno. Después traducimos el OID para asegurarnos
# con snmptranlate -To .1.3.6.1.4.1.2021 por ejemplo.

# Habilitamos los UDP de cualquier máquina.
sed -i "/^agentAddress/s/^/#/g" /etc/snmp/snmpd.conf
echo "agentAddress udp:161" >> /etc/snmp/snmpd.conf

# Modificamos sysLocation y sysContact
sed -i "/^sysLocation/s/^/#/g" /etc/snmp/snmpd.conf
echo "sysLocation $(hostname) in the lab" >> /etc/snmp/snmpd.conf
sed -i "/^sysContact/s/^/#/g" /etc/snmp/snmpd.conf
echo "sysContact germantelmo.eizaguirre@estudiants.urv.cat" >> /etc/snmp/snmpd.conf

# Creamos las vistas con su community string.
echo " 
com2sec mis_datos localhost secret14
group grupo_local v2c mis_datos
view vistalocal excluded .1
view vistalocal included .1.3.6.1.2.1
view vistalocal included .1.3.6.1.4.1.2021
access grupo_local \"\" v2c noauth exact vistalocal none none
" >> /etc/snmp/snmpd.conf

# Procs necesarios para cada máquina.
echo "proc openssh-server" >> /etc/snmp/snmpd.conf

if [ $(hostname) = "Client" ]; then
	echo "proc rsyslog" >> /etc/snmp/snmpd.conf
fi
if [ $(hostname) = "Server" ]; then
	echo "proc rsyslog" >> /etc/snmp/snmpd.conf
	echo "proc apache2" >> /etc/snmp/snmpd.conf
fi
if [ $(hostname) = "GSX" ]; then
	echo "proc isc-dhcp-server" >> /etc/snmp/snmpd.conf
	echo "proc bind9" >> /etc/snmp/snmpd.conf
fi

echo " createUser gsxViewer SHA \"autent14\"
createUser gsxAdmin SHA \"autent14\" DES \"secret14\"
rouser gsxViewer auth .1
rwuser gsxAdmin authPriv .1
" > aux.txt

cp /etc/snmp/snmpd.conf aux_snmpd.conf
cat aux.txt aux_snmpd.conf > /etc/snmp/snmpd.conf

rm aux.txt
rm aux_snmpd.conf

service snmpd restart

exit 0
