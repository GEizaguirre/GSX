#! /bin/bash

# Nombre: onoff_proc

# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

# Versión: 1.0
# Data última versión: 28-02-2019 

# Descripción: Este script detiene los procesos que consuman más de 5 minutos de 
# CPU o que ocupen más de 1GB de VSZ (Virtual Memory Size) entre las 8 y las 21h 
# de los dias laborales. Y se encenderan de nuevo a partir de las 21h hasta las 8h.
# Los id de los procesos supsendidos se guardan en proc_sus.txt

# Argumentos:
# 1	Opción

# Opciones:
# -s Parar proceso (Stop)
# -r Reanudar proceso (Resume)
# -h Mostrar ayuda (Help)

function show_help {
	echo "
 Nombre: onoff_prov

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 Versión: 1.0
 Data última versión: 28-02-2019 

 Descripción: Este script detiene los procesos que consuman más de 5 minutos de 
 CPU o que ocupen más de 1GB de VSZ (Virtual Memory Size) entre las 8 y las 21h 
 de los dias laborales. Y se encenderan de nuevo a partir de las 21h hasta las 8h.

 Opciones:
 -s	Para los procesos que cumplen las condiciones descritas anteriormente
 -r	Reanuda los procesos que cumplen las condiciones descritas anteriormente
 -h	Devuelve una descripción del uso del script
"
}

#comprobar si es superusuario
if [ "$EUID" -ne 0 ]; then
	echo " Acceso denegado: el script debe ejecutarse en modo superusuario.
	"
	exit 1
fi

#comprovar argumentos
if [ $# -lt 1 ]; then
	echo "Este script requiere un argumento. Mostrando la ayuda:"
	show_help
	exit 1
fi

#llamada al help
if [ $1 = "-h" ]; then
	show_help
#si se quiere parar los procesos
elif [ $1 = "-s" ]; then
	echo "Los siguientes procesos seran suspendidos:"
	processes=($(ps aux | awk '$5>=1000000||$10>="5:00"{print $2}'))	# Cargamos los procesos con 1GB de VSZ o 5 min de CPU
	echo ${processes[@]} > proc_sus.txt					# Los guardamos en un fichero
	for i in "${processes[@]:1}" 
	do 
		echo "PID: $i"							# Mostramos el proceso por pantalla
		kill -STOP $i							# Paramos el proceso
	done
#si se quiere restaurar los procesos
elif [ $1 = "-r" ]; then
	echo "Los siguientes procesos han sido reanudados:"
	mapfile -t processes < proc_sus.txt					# Cargamos los procesos guardados en el fichero
	processes=($(echo ${processes[0]} | tr " " "\n"))			# Pasemos cada pid a una posición del array
	for i in "${processes[@]:1}"
	do 
		kill -CONT $i							# Restauramos el proceso
		echo "PID: $i"							# Mostramos el proceso por pantalla
	done
else
	echo "ERROR, la opción introducida no es correcta. Prueba con -s, -r o -h."
	exit 1
fi

exit 0
