#! /bin/bash

# Nombre: preparar_servicio_restaurar.sh

# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

# Versión: 3.0
# Data última versión: 04-03-2019

# Descripción: Este script instala/desinstala el servicio para restaurar backups.
# Para intalar el servicio hay que ejecutar el script en modo superusuario. Para 
# desintalarlo hay que añadir la opción '-u'.

# Opciones:
# -u Desinstalar servicio (Uninstall)
# -h Mostrar ayuda (Help)

function show_help {
	echo "
 Nombre: preparar_servicio_restaurar.sh

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 Versión: 3.0
 Data última versión: 04-03-2019

 Descripción: Este script instala/desinstala el servicio para restaurar backups.
 Para intalar el servicio hay que ejecutar el script en modo superusuario. Para 
 desintalarlo hay que añadir la opción '-u'.

 Opciones:
 -u Desinstalar servicio (Uninstall)
 -h Mostrar ayuda (Help)
"
}

if [ "$EUID" -ne 0 ]; then						# Comprobar modo superusuario
	echo "Acceso denegado: el script debe ejecutarse en modo superusuario."
	exit 1
fi

if [ $# -lt 1 ]; then							# Comprobar que no hay parametros
	if [ ! -e /etc/init.d/restaurar.sh ]; then			# Comprobar si no existe el servicio, entonces se puede instalar
		cp /admin/restaurar.sh /etc/init.d/restaurar.sh
		chmod 755 /etc/init.d/restaurar.sh
		ln -s /etc/init.d/restaurar.sh /etc/rc5.d/S10restaurar

		echo "El servicio de restauracion backup se ha instalado correctamente. "
		exit 0
	else
		echo "ERROR, El servicio ya esta instalado. Si desea desisntalarlo ejecute la opció '-u':'./preparar_servicio_restaurar.sh -u'."
		exit 1
	fi
elif [ "$1" = "-h" ]; then
	show_help
	exit 0
elif [ "$1" = "-u" ]; then
	if [ -e /etc/init.d/restaurar.sh ]; then			# Comprobar si existe el servicio, si no existe no se puede desinstalar
		rm /etc/rc5.d/S10restaurar
		rm /etc/init.d/restaurar.sh

		echo "El servicio de restauracion backup ha sido desinstalado. "
		exit 0
	else
		echo "ERROR, El servicio no existe. No se puede desinstalar."
		exit 1
	fi
fi
