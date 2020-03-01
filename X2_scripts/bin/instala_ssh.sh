# !/bin/bash

# 
# Script para instalar el servicio ssh en una máquina.
#

apt update
apt-get -y install openssh-server
echo " Servicio SSH instalado."

exit 0
