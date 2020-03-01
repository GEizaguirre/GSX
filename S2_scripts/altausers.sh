#! /bin/bash
# altausers.sh
#
# Nombre: altausers.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 12-05-2019 V 1.0
# 
# Descripción:
# Recibe como parámetro un fichero con una lista datos de usuarios
# y genera un login para cada uno asociado al ID de usuario (DNI)
# y con el número de contraseña como contraseña.
# El nombre de login está formado por el nombre y la primera letra
# de cada apellido en mayúsculas.
# En caso de existir un login para un usuario del mismo nombre 
# previamente, le concatena un índex creciente al login.
#
# Argumentos:
# 1. Fichero con datos de usuarios separados por comas.
# Formato: 
# <DNI>,<Nombre>,<Apellido1>,<Apellido2>,<Telefono>,<Grupo1>,<Grupo2>,...
# 
# Opciones:
# -h	Devuelve una descripción del script.
#
# Decisiones de diseño:
# Crea aquellos grupos de la lista que no existan en el sistema.
# El primer grupo de la lista se asigna como primario.
# Para comprobar que el registro es correcto se comprueba que el 
# resultado de psck y grck al inicio y al final sea igual (para 
# que no genere error en caso de que el sistema tenga algún error
# de este tipo independiente del script).
#

PATH="$PATH:/usr/admin"

# Comprobaciones iniciales.
if [ $EUID -ne 0 ]; then
	echo " altausers.sh debe ejecutarse en modo root." >&2
       	exit 1
elif [ $# -ne 1 ]; then
	echo " El número de argumentos no es correcto." >&2
	exit 1
elif [ "$1" = "-h" ]; then
	echo " Recibe como parámetro un fichero con una lista datos de usuarios
 y genera un login para cada uno asociado al ID de usuario (DNI)
 y con el número de contraseña como contraseña.
 El nombre de login está formado por el nombre y la primera letra
 de cada apellido en mayúsculas.
 En caso de existir un login para un usuario del mismo nombre 
 previamente, le concatena un índex creciente al login.

 Argumentos:
 1. Fichero con datos de usuarios separados por comas.
 Formato: 
 <DNI>,<Nombre>,<Apellido1>,<Apellido2>,<Telefono>,<Grupo1>,<Grupo2>,...
 
 Opciones:
 -h	Devuelve una descripción del script.
"
	exit 0
elif ! [[ -f "$1" ]]; then
	echo " El fichero $1 no existe." >&2
	exit 1
fi

# Verificación del fichero de configuración.
if [ ! -d /root/conf ]; then mkdir /root/conf; fi
if [ ! -f /root/conf/.usuaris ]; then
	echo " El fichero de configuración (/root/conf/.usuaris) no existe, se
se creará con los valores por defecto.
	GS_DSHELL=/bin/bash
	GS_DHOME=/usuaris
	GS_SKEL=/root/conf/gs_skel
	GS_minuid=400
	GS_maxuid=499
	GS_mingid=400
	GS_maxgid=499"

	echo -e "GS_DSHELL=/bin/bash\n
	GS_DHOME=/usuaris/\n
	GS_SKEL=/root/conf/gs_skel\n
	GS_minuid=400
	GS_maxuid=499\n
	GS_mingid=400
	GS_maxgid=499" > /root/conf/.usuaris
fi

source /root/conf/.usuaris

# Comprobamos si la configuración es adecuada.
if [ ! -f $GS_DSHELL ]; then
	echo " La terminal de usuario ($GS_DSHELL) no existe." >&2
	exit 1
elif [ ! -d $GS_DHOME ]; then
	echo " El path de carpetas de usuario ($GS_DHOME) no existe." >&2
	exit 1
elif [ ! -d $GS_SKEL ]; then
	echo " El directorio esqueleto ($GS_SKEL) no existe."
	# Comprobamos si existe un modelo de skel en el path actual.
	if [ -d "gs_skel" ]; then
		echo " Se copiará el directorio por defecto gs_skel."
		cp -pr gs_skel /root/conf/gs_skel
	else
		echo " Alta de usuarios cancelado por falta de gs_skel." >&2
		exit 1
	fi
fi

# Copia de seguridad del estado actual de la configuración de
# usuarios.

test ! -d /back/usermng.bck.d  && mkdir /back/usermng.bck.d
# Guardamos copias de seguridad de los ficheros de configuración
# que se modificarán manteniendo los permisos (según se indica
# que se modificarán en el manual de useradd).
tar -cpf  /back/usermng.bck.d/passwd.tar	/etc/passwd 2> /dev/null
tar -cpf  /back/usermng.bck.d/shadow.tar	/etc/shadow  2> /dev/null
tar -cpf  /back/usermng.bck.d/group.tar	/etc/group  2> /dev/null
tar -cpf  /back/usermng.bck.d/subuid.tar	/etc/subuid  2> /dev/null
tar -cpf  /back/usermng.bck.d/gshadow.tar	/etc/gshadow  2> /dev/null
tar -cpf  /back/usermng.bck.d/subgid.tar	/etc/subgid  2> /dev/null

# Guardamos resultados de pwck y grpck para evaluar el resultado final.
pwck0=$(pwck)
pwck0_ret=$?
grpck0=$(grpck)
grpck0_ret=$?

declare -A grs
while IFS=, read -ra arr; do

	DNI=${arr[0]}
	nom=${arr[1]}
	ap1=${arr[2]}
	ap2=${arr[3]}
	tfn=${arr[4]}
	gr1=${arr[5]}
	login="$nom${ap1:0:1}${ap2:0:1}"

	# Comprobamos que el DNI no esté ya registrado.
	if [ ! -z $(cat /etc/passwd | grep -w $DNI) ]; then
		echo "El usuario $DNI ya está registrado." >&2
		i=6
		while [ ${arr[i]} ]; do
			((i+=1))
		done
		continue 
	fi
	
	
	# Comprobar si existe el login
	id -u $login > /dev/null 2> /dev/null
	# Si existe el login, añadir usuario con index creciente
	if [ $? -eq 0 ]; then
		index=$(cat /etc/passwd | cut -f 1 -d ':' | grep $login | sort | awk -F "$login" '{print $2}' | sort | tail -1)
		index=$((index+1))
		login="$login$index"
	fi
	dir="$GS_DHOME$login"

	# Comprobar si existen grupos, y en caso contrario crearlos
	egrep -q "^$gr1:" /etc/group
	if [ $? -ne 0 ]; then groupadd "${gr1}"; fi
	
	i=6
	while [ ${arr[i]} ]; do
		grs[$((i-6))]=${arr[i]}
		egrep -q "^${arr[i]}:" /etc/group
		if [ $? -ne 0 ]; then groupadd "${arr[i]}"; fi
		((i+=1))
	done

	# useradd requiere la contraseña encriptada.
	psword=$(openssl passwd $tfn 2> /dev/null)
	secs=$( IFS=$','; echo "${grs[*]}" )
	# Añadimos el nuevo usuario con los campos especificados (la comanda es diferente
	# dependiendo de si tiene grupos secundarios o no).
	# El parámetro -k sobreescribe los valores por defecto de /etc/adduser.conf.
	if [ $i -eq 6 ]; then useradd -m -c $DNI -d $dir -g $gr1 -k $GS_SKEL -p $psword -s $GS_DSHELL -K UID_MIN=$GS_minuid -K UID_MAX=$GS_maxuid -K GID_MIN=$GS_mingid -K GID_MAX=$GS_maxgid $login
	else useradd -m -c $DNI -d $dir -g $gr1 -G $secs -k $GS_SKEL -p $psword -s $GS_DSHELL -K UID_MIN=$GS_minuid -K UID_MAX=$GS_maxuid -K GID_MIN=$GS_mingid -K GID_MAX=$GS_maxgid $login
	fi	
	unset grs

done < $1

# Evaluamos el resultado final con pwck y grpck.
pwck1=$(pwck)
pwck1_ret=$?
if ! [ "$pwck1_ret" == "$pwck0_ret" ] || ! [ "$pwck0" == "$pwck1" ] 
then
	echo " Error en chequeo de contraseñas. Se anularán los cambios." >&2
	restaura_usrmng.sh
	exit 1
else
	grpck1=$(grpck)
	grpck1_ret=$?
	if ! [ "$grpck1_ret" == "$grpck0_ret" ] || ! [ "$grpck0" == "$grpck1" ] 
	then
		echo " Error en chequeo de grupos. Se anularán los cambios." >&2
		restaura_usrmng.sh
		exit 1
	fi
fi

echo " Alta de usuarios finalizada correctamente."

exit 0
