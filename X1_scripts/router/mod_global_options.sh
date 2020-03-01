#!/bin/bash

# Forwarding de queries desconocidas
echo -e "options {\n\tdirectory \"/var/cache/bind\";\n\tforwarders {" > /etc/bind/named.conf.options
IFS=$'\n'
for line in $(cat /etc/resolv.conf)
do
	if [ "$(echo $line | egrep -e "[0-9].*")" != "" ]
	then
		echo -e "\t\t$(echo $line | egrep -e "[0-9].*" | cut -d ' ' -f2);" >> /etc/bind/named.conf.options
	fi
done
echo -e "\t};\n" >> /etc/bind/named.conf.options

echo -e "\tallow-recursion { 172.16.4.0/16; };
\tallow-query { 172.16.4.0/16; 198.18.14.0/24; };
\tallow-transfer { 127.0.0.1; };
};" >> /etc/bind/named.conf.options

exit 0
