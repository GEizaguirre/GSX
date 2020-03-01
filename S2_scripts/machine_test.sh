# !/bin/bash

# Nombre: machine_test.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
#
# 12-05-2019 V 1.8
# 
# Descripción:
# Ejecuta cada uno de los programas en C para la memoria, el procesador 
# y el disco. Y genera los resultados de monitoritzación ́(vmstat, iostat) 
# en un fichero denominado machine_test_results.txt.
# 
# Opciones:
# -h	Devuelve una descripción del script.
#
# Requisitos:
# Para que la comanda iostat se ejecute correctamente es necesario 
# intalar el paquete 'sysstat'. Ejecutar en modo superusuario la comanda:
# apt-get install sysstat
# Y que los ficheros .c de los programas C utilizados se encuentren 
# en la misma carpeta que este script.
#

function show_help {
	echo"
 Nombre: machine_test.sh
 Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre

 12-05-2019 V 1.8
 
 Descripción:
 Ejecuta cada uno de los programas en C para la memoria, el procesador 
 y el disco. Y genera los resultados de monitoritzación ́(vmstat, iostat) 
 en un fichero denominado machine_test_results.txt.
 
 Opciones:
 -h	Devuelve una descripción del script.

 Requisitos:
 Para que la comanda iostat se ejecute correctamente es necesario 
 intalar el paquete 'sysstat'. Ejecutar en modo superusuario la comanda:
 apt-get install sysstat
 Y que los ficheros .c de los programas C utilizados se encuentren 
 en la misma carpeta que este script.
"
}

# Opción de mostrar ayuda.
if [ "$1" = "-h" ]; then
	show_help
	exit 0;
fi

# Generemos el fichero con los resultados
echo "Machine performance analysis" > machine_test_results.txt

# Generemos los objectos de los programas C(make)
gcc -o intensive_mem intensive_mem.c
gcc -o intensive_cpu intensive_cpu.c
gcc -o intensive_disk intensive_disk.c

#----------MEMORY----------
echo -e "\nMEM TEST RESULTS" >> machine_test_results.txt
echo "VMSTAT" >> machine_test_results.txt
timeout 10 ./intensive_mem &
vmstat -an 1 10 >> machine_test_results.txt

#----------CPU----------
echo -e "\nCPU TEST RESULTS" >> machine_test_results.txt
echo "VMSTAT" >> machine_test_results.txt
timeout 10 ./intensive_cpu &
vmstat -an 1 10 >> machine_test_results.txt
echo "IOSTAT" >> machine_test_results.txt
timeout 10 ./intensive_cpu &
iostat -cy 1 10 >> machine_test_results.txt

#----------DISK----------
echo -e "\nDISK TEST RESULTS" >> machine_test_results.txt
echo "VMSTAT" >> machine_test_results.txt
# Ejecutamos el programa en background. 
# He comprobado que tarda aprox 21 segundos.
timeout 15 ./intensive_disk &
# Analizamos los resultados de memoria (-d) por 24 segundos cada 
# 3 segundos.
vmstat -d 3 6 >> machine_test_results.txt
echo "IOSTAT" >> machine_test_results.txt
# Ejecutamos iostat en los mismo plazos de vmstat mostrando el 
# rendimiento de los dispositivos (-d) y excluyendo un resumen
# inicial del rendimiento desde el boot.
timeout 15 ./intensive_disk &
iostat -dy 3 6 >> machine_test_results.txt

# Eliminamos los objetos generados para la ejecución de los programas C
# y el fichero IOIntensive.txt (que esta protegido porque lo crea el 
# programa intensive_disk.c)
rm intensive_mem
rm intensive_cpu
rm intensive_disk
chmod 644 IOIntensive.txt
rm IOIntensive.txt

exit 0
