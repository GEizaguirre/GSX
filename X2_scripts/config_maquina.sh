#! /bin/bash
#
# config_maquina.sh
# Autores: Bernat Boscá, Alber Canellas, German Telmo Eizaguirre
# 23-03-2019 Versión 1.0
#
# Descripción:
#  script general de configuración de las máquinas de la red de la
#  entrega X1 de la asignatura de Gestión de Sistemas y Redes. Según
#  la elección del usuario instala la configuración de Router, Server
#  o Intern. Instala servicios rsyslog, DHCP y DNS.

PATH="$PATH:/home/milax"

source def_interficies.sh

# Montaje espacio adicional (para las máquinas virtuales)
# mount /dev/sdc1 /var/cache/apt

if [ $EUID -ne 0 ]; then (echo " Debe ejecutarse en modo root." >&2; exit 1)
fi

echo " ¿Qué máquina desea instalar?"
echo " 1) Router 2) Server 3) Client"
read option
case "$option" in
	"1") router/config_router.sh
	;;
	"2") server/config_server.sh
	;;
	"3") intern/config_client.sh
	;;
	*) (echo " Opción incorrecta." >&2; exit 1)
	;;
esac

exit 0
