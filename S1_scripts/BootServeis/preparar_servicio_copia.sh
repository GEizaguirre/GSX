#! /bin/bash

# 
# Nombre: preparar_servicio.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 3-3-2019 V 1.0
#
# Descripción:
# Script para la instalación y habilitación de la unidad servicio_copia
# en systemd.
# Debe ejecutarse en modo root.
# 
# Opciones:
# -h	Devuelve una descripción del script.
# 
# Decisiones de diseño:
# Requiere que los scripts copia_seguridad.sh y gpgp.sh se encuentren en 
# el directorio /admin.

# Comprueba que se esté ejecutando en root (neecsario para instalar unidades
# en systemd).
if [ "$EUID" -ne 0 ]; then
	echo " Acceso denegado: el script debe ejecutarse en modo superusuario.
	"
	exit 1
fi

# Copia los scripts necesarios en /usr/bin.
cp /admin/copia_seguridad.sh /usr/bin/copia_seguridad.sh
chmod 544 /usr/bin/copia_seguridad.sh
cp /admin/gpgp.sh /usr/bin/gpgp.sh
chmod 544 /usr/bin/gpgp.sh

# Copia el archivo .service de la unidad en la carpeta de systemd.
cp /admin/servicio_copia.service /lib/systemd/system/servicio_copia.service

# Habilita el servicio.
systemctl enable servicio_copia.service --now
systemctl daemon-reload

echo " El servicio de copia de seguridad ha sido instalado. "

exit 0
