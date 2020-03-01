# !/bin/bash

source /home/milax/def_interficies.sh

NSIP=$(ip addr show $IFISP | grep " inet " | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)
NSNET=$(ip -o -f inet addr show | grep $IFISP | tr -s ' ' | cut -d ' ' -f 4)
iptables -t nat -j SNAT -A POSTROUTING -s 198.18.14.19/28 -o $IFISP\
 --to-source $NSIP
iptables -t nat -j SNAT -A POSTROUTING -s 172.16.4/24 -o $IFISP\
 --to-source $NSIP
iptables -t nat -A PREROUTING -i $IFISP -d $NSIP -p tcp\
 --dport 80 -j DNAT --to-destination 198.18.14.19:80
#iptables -t nat -A POSTROUTING -p tcp -d 198.18.14.19 --dport 80 -j SNAT\
# --to-source $NSIP
iptables -t nat -j DNAT -A PREROUTING -i $IFISP -d $NSIP -p tcp\
 --dport 443 --to-destination 198.18.14.19:443
iptables -t nat -A PREROUTING -i $IFISP -d $NSIP -p tcp\
 --dport 2222 -j DNAT --to-destination 198.18.14.19:22

