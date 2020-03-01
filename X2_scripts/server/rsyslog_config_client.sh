#! /bin/bash
#
# rsyslog_config_client.sh
# Autores: Bernat Boscá, Albert CAnellas, German Telmo Eizaguirre
# 23-03-2019 Versión 1.0
#
# Descripción:	
#  Instala la configuración del cliente del servicio remoto 
#  rsyslog.

PATH="$PATH:/home/milax"

cp -i server/copia_90-remot.conf /etc/rsyslog.d/90-remot.conf

service rsyslog restart

exit 0
