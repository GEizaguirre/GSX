# !/bin/bash

source /home/milax/def_interficies.sh
PATH="$PATH:/home/milax"

# Eliminamos reglas previas.
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Permitimos comunicación con el propio router.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Políticas restrictivas por defecto.
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Aceptar respuestas de conexiones establecidas.
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT

NSIP=$(ip addr show $IFISP | grep " inet " | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)
NSNET=$(ip -o -f inet addr show | grep enp0s3 | tr -s ' ' | cut -d ' ' -f 4)
router/iptables_basic_config.sh

# Configuración cortafuegos DNS.
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT

# Configuración ping.
iptables -A FORWARD -p icmp --icmp-type 8 -i $IFDMZ -o $IFINT -j DROP 
iptables -A FORWARD -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT

# Configuración SSH.
iptables -A FORWARD -p tcp -i $IFDMZ -o $IFINT -j DROP
iptables -A FORWARD -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Comunicación con direcciones privadas INT->DMZ.
iptables -A FORWARD -s 172.16.4/24 -d 198.18.14.19/28 -j ACCEPT

iptables -A OUTPUT -p tcp -j ACCEPT
iptables -A FORWARD -p tcp -i $IFISP -o $IFDMZ -j ACCEPT
iptables -A FORWARD -p tcp -s 172.16.4.2/24 -j ACCEPT
iptables -A FORWARD -p tcp -s 198.18.14.19/28 -j ACCEPT

# Permitir smnp
iptables -A FORWARD -p udp --dport 161 -j ACCEPT

exit 0
