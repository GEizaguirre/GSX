#!/bin/sh

# Autor:	Josep M. Banus, GSX 2018
# Descripcio:
# Troba les MACs de les xarxes internes per a configurar el dhcpd.
# Utilitza el PING6 a tots els nodes d'una lan.
# Afegeix el resultat al final del fitxer de configuracio.
# Cal fer un altre script que canvii els fitxers de config amb aquestes MACs
#
# ULL: Sols funciona be si hi ha una maquina remota per LAN.
# Altrament tambe es descobreixen les MACs pero se n'ha de triar una manualment.

# Parametres: cap
# Retorn: boolea indicant si n'ha trobat
# Requisits: IPv6 activat i ping6
# Versio: 1.0

if [ $(id -u) != 0 ]; then
	echo "Has de ser root per a executar-me !"
	exit
fi

definicions="def_interficies.sh"
if [ ! -f ./$definicions ]; then
	echo "ERROR: no trobo el fitxer '$definicions'"
	echo "Primer hauries d'executar 'prepara_cables_fisics.py'"
	exit 0
fi

ipv6=$(sysctl -n net.ipv6.conf.all.disable_ipv6)
if [ $ipv6 -ne 0 ]; then
	echo "Error: sembla que no tenim IPv6 activat."
	exit 0
fi

list_intf=$(ip link show | grep "^[0-9]\+:" | grep -vi LOOPBACK | cut -f 2 -d ':' | tr -d ' ' | sed "s/@.*$//")

exit_intf=$(ip route | grep -i default | head -1 | cut -f5 -d ' ')
exit_mac=$(ip link show dev $exit_intf | grep ether | awk '{ print $2 }')
exit_ipv6=$(ip address show dev $exit_intf | grep inet6 | awk '{ print $2 }'| cut -f1 -d'/')
if [ ${#exit_ipv6} -eq 0 ]; then
	echo "Avis: sembla que no tenim IPv6 a la sortida cap a Internet."
fi

for intf in $list_intf
do
	if [ "$intf" != "$exit_intf" ]; then
		# hauria de estar UP, pero, per si de cas ...
		ip link set dev $intf up
		# esborrem informacio antiga
		ip neigh flush dev $intf

		my_ipv6=$(ip address show dev $intf | grep inet6 | awk '{ print $2 }'| cut -f1 -d'/')
		echo "Provant la xarxa que hi ha a '$intf' ..."
		# ping multicast a tots els nodes de la LAN
		ping6 -c7 ff02::1 -I $intf | grep -v $my_ipv6 | grep "bytes from"
		ip neigh | grep --color "$intf lladdr"
	fi
done

retorn=0
if [ -f ./$definicions ]; then
	. ./$definicions
	echo "\nActualitzant les MACs al fitxer de definicions '$definicions'"
	echo "\n# MACs d'altres maquines:" >> $definicions
	ip neigh show dev $IFDMZ | grep " lladdr" 
	ip neigh show dev $IFINT | grep " lladdr"
	macdmz=$(ip neigh show dev $IFDMZ | grep " lladdr" | awk '{ print $3 }')
	macint=$(ip neigh show dev $IFINT | grep " lladdr" | awk '{ print $3 }')
	# actualitzar el fitxer de configuracio
	if [ ! -z $macdmz ]; then
		echo "MacServer=\"$macdmz\""
		echo "MacServer=\"$macdmz\"" >> $definicions
		retorn=1
	fi
	if [ ! -z $macint ]; then
		echo "MacIntern=\"$macint\""
		echo "MacIntern=\"$macint\"" >> $definicions
		retorn=1
	fi
	cat $definicions
else
	# al menys mostrar el que tenim
	ip neigh | grep " lladdr"
fi

exit $retorn

# Cal fer un altre script que canvii els fitxers de config amb aquestes MACs
# per exemple
# sed -i "%s/$old_mac1/$MacServer/" /etc/dhcp/dhcpd.conf
