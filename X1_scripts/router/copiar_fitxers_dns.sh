#!/bin/bash

# Script per a copiar els fitxers al destí

# Aquest script s'ha de executar en mode superusuari

PATH="$PATH:/home/milax"

#ip_completa=$(ip a | grep -e  "inet.*brd" | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)

# Obtenemos la ip externa del router
ip_completa=$(dig +short myip.opendns.com @resolver1.opendns.com)

ISP_B1=$(echo $ip_completa | cut -d '.' -f 1)
ISP_B2=$(echo $ip_completa | cut -d '.' -f 2)
ISP_B3=$(echo $ip_completa | cut -d '.' -f 3)
ISP_B4=$(echo $ip_completa | cut -d '.' -f 4)

cp -p router/fitxers_dns/db.10.bck router/fitxers_dns/db.10
cp -p router/fitxers_dns/grup14.gsx.db.bck router/fitxers_dns/grup14.gsx.db
cp -p router/named.conf.local.bck router/named.conf.local

sed -i "s/ISP_B1/$ISP_B1/g" router/fitxers_dns/db.10
sed -i "s/ISP_B1/$ISP_B1/g" router/fitxers_dns/grup14.gsx.db
sed -i "s/ISP_B1/$ISP_B1/g" router/named.conf.local
sed -i "s/ISP_B2/$ISP_B2/g" router/fitxers_dns/db.10
sed -i "s/ISP_B2/$ISP_B2/g" router/fitxers_dns/grup14.gsx.db
sed -i "s/ISP_B2/$ISP_B2/g" router/named.conf.local

sed -i "s/ISP_B3/$ISP_B3/g" router/fitxers_dns/db.10
sed -i "s/ISP_B3/$ISP_B3/g" router/fitxers_dns/grup14.gsx.db
sed -i "s/ISP_B3/$ISP_B3/g" router/named.conf.local

sed -i "s/ISP_B4/$ISP_B4/g" router/fitxers_dns/db.10
sed -i "s/ISP_B4/$ISP_B4/g" router/fitxers_dns/grup14.gsx.db
sed -i "s/ISP_B4/$ISP_B4/g" router/named.conf.local



for file in $(ls router/fitxers_dns)
do	
	cp router/fitxers_dns/$file /var/cache/bind/$file
done

cp router/named.conf.local /etc/bind/named.conf.local

rm router/fitxers_dns/db.10
rm router/fitxers_dns/grup14.gsx.db
rm router/named.conf.local

exit 0
