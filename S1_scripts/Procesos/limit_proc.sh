#!/bin/bash

# Nombre: lim_proc.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 26-02-2019 V 1.0
# Limita el número máximo de procesos del usuario que ejecuta el
# script y limita el uso de la bash en la que se ejecuta el script
# y sus procesos hijos a la CPU cuyo número recibe como argumento.
# Argumentos:
# 1-	Número de la CPU a la que se limitarán la bash y sus hijos
# Opciones:
# -h	Devuelve una descripción del uso del script
# 
# Decisiones de diseño:
#
# Generamos un cgroup para el usuario porque la comanda ulimit -u
# no nos permite limitar el número de procesos del usuario 
# globalmente, sino que sus modificaciones se limitan a la bash
# que lo llaman.
# El juego de pruebas, sin embargo, lo realizamos con ulimit -u,
# con el que establecimos el número de procesos límite a unos 250.


# función para mostrar ayuda sobre el script

function show_help {
	echo "
 Nombre: limit_proc

 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 	26-02-2019 V 1.0

 Limita el número máximo de procesos del usuario cuyo nombre se 
 recibe como parámetro a 250 y limita el uso de la bash en la que
 se ejecuta el script y sus procesos hijos a la CPU cuyo ID recibe como 
 argumento.

 Argumentos:
 1	Nombre del usuario cuyos procesos se quieren limitar
 2	ID de la CPU a la que se limitarán la bash y sus hijos

 Opciones:
 -h	Devuelve una descripción del uso del script
"
}

# comprobamos los parámetros de entrada y las opciones del script

if [ "$1" = "-h" ]; then
	show_help
	exit 0;
fi

if [ $# -ne 2 ]; then
	echo " Número de argumentos incorrecto:
	Necesario:
	1 . id de la CPU a la que limitar la bash
	2 . nombre del usuario cuyos procesos se limitarán." >&2
	exit 1
fi

# comprobar que el usuario especificado existe
# buscamos si hay pswd guardado para dicho user.
uexists=$(grep -c "^${2}:" /etc/passwd)

if [ $uexists -eq 0 ]; then
	echo " Valor de argumento incorrecto:
	El usuario especificado no existe. " >&2
	exit 1
fi


# comprobar que el número de CPU es correcto
# otenemos el número de cpus del sistema leyendo el número 
# de ids asignados en /proc/cpuinfo. Los IDs de las CPUs
# disponibles se asignan de 0 a num_CPUS - 1.
# En máquina virtual solo hay una CPU disponible. 

num_cpu=$( grep -e '^core id' /proc/cpuinfo | sort -u | wc -l) 
if [ $1 -ge $num_cpu ] || [ $1 -lt 0 ]; then
	echo " Valor de argumento incorrecto:
	El número especificado de CPU no es correcto. " >&2
	exit 1
fi

# Comprobamos que el script se haya ejecutado en root comprobando
# el ID del usuario efectivo.

if [ "$EUID" -ne 0 ]; then
	echo "Acceso denegado: el script debe ejecutarse en modo superusuario."
	exit 1
fi

# Limitar número máximo de procesos de usuario.
# Modificamos el fichero limits.conf para que los cambios sean 
# permanentes. 
# Establecemos un límite hard porque consideramos que estamos
# generando scripts que ejecutará el administrador del sistema
# y por lo tanto los límites no deberán poder ser sobrepasados
# por el resto de usuarios.

# Detectamos si se han establecido límites hard previos.
# Eliminamos posibles límites previos.
sed -i '/milax *hard *nproc/d' /etc/security/limits.conf

echo "$2 hard nproc 274" | tee -a /etc/security/limits.conf > /dev/null
echo " El límite de procesos del usuario $2 se ha establecido
 a 250. Reinicie el sistema para hacer efectivo el ajuste."

# Generamos un cgroup para la bash y sus procesos hijos (si no existe).
if ! [[ -d /sys/fs/cgroup/cpuset/grupo_cpu$1 ]]; then 
	mkdir /sys/fs/cgroup/cpuset/grupo_cpu$1
fi

# Inicializamos los ficheros necesarios (nodos, cpus y pid asociado)
echo 0 > /sys/fs/cgroup/cpuset/grupo_cpu$1/cpuset.mems
echo $1 > /sys/fs/cgroup/cpuset/grupo_cpu$1/cpuset.cpus

# Debemos obtener el PID de la bash que llama al script para archivarlo
# en el cgroup. Como el script se llama en sudo (sudo es el proceso padre
# de limit_proc.sh debemos conocer el pid del proceso padre de sudo.
bash_pid=$(ps -l | grep sudo | tr -s ' ' | cut -d ' ' -f 5)
echo $bash_pid > /sys/fs/cgroup/cpuset/grupo_cpu$1/tasks

exit 0
