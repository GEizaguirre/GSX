#! /bin/bash
# canviusers.sh
#
# Autores: Bernat Boscá, German Telmo Eizaguirre, Albert Canellas
# 9-05-2019 Versión 1.0
#
# passwd user -l (desactivar)
# passwd user -u (activar)

# Comprobaciones iniciales.
if [ $EUID -ne 0 ]; then
	echo " canviausers.sh debe ejecutarse en modo root." >&2
	exit 1
elif [ $# -ne 1 ]; then
	echo " El número de argumentos no es correcto." >&2
	exit 1
elif [ "$1" = "-h" ]; then
	echo -e "Script que desahiblita o habilita un usuario pasado por parametro."
	exit 0
fi

#Mirar si el usuario existe
id -u $1
if [ $? -eq 1 ]; then
	echo "El usuario no existe."
	exit 1
fi
echo "Pulsa \"e\" para habilitar o \"d\" para dishabilitar el usuario"
read op
#Habilitar usuario
if [ $op = "e" ]; then
	passwd $1 -u 
#Deshabilitar usuario
elif [ $op = "d" ]; then
	passwd $1 -l 
fi




exit 0
