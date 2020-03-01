# !/bin/bash

# Nombre: config_show_disk_info.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 26-02-2019 V 1.0
#
# Instala el script show_disk_info.sh para que se le muestre el espacio
# de disco de su directorio HOME al iniciar un terminal.
#
# Opciones:
# -h	Devuelve una descripción del uso del script
# 
# Decisiones de diseño:
#
# Ejecutamos show_disk_info.sh desde /etc/bash.bashrc para
# que se ejecute cada vez que un usuario entra en un terminal.
# De este modo también se ejecuta cuando se abre un terminal.
# Alternativamente, si se ejecuta desde /etc/profile, solo
# se ejecuta cuando se logea un usuario, y no cuando se abre
# una terminal.

function show_help {
	echo " Instala el script show_disk_info.sh para que se le muestre el espacio
 de disco de su directorio HOME al iniciar un terminal.

 Opciones:
 -h    Devuelve una descripción del uso del script
"
}

if [ "$1" = "-h" ]; then
	show_help
	exit 0;
fi

if [ "$EUID" -ne 0 ]; then
	echo "Acceso denegado: el script debe ejecutarse en modo superusuario."
	exit 1
fi

if ! [ -f "/usr/admin/show_disk_info.sh" ]; then
	echo " No se encuentra el script show_disk_info.sh en /usr/admin" >&2
	exit 1
fi

# Añadimos la ejecución de show_disk_info.sh si no existe ya.
if [ -z "$(cat /etc/bash.bashrc | grep /usr/admin/show_disk_info.sh)" ]; then
	echo "/usr/admin/show_disk_info.sh" >> /etc/bash.bashrc
else echo " show_disk_info.sh ya está instalado."
fi

exit 0
