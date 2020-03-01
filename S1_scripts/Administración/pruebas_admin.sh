#! /bin/bash

# Descripción: juego de pruebas para gpgp.sh y rpgp.sh.

mkdir /usr/pruebas
touch /usr/pruebas/info_archivos.txt
touch /usr/pruebas/archivo_a.txt
chmod 666 /usr/pruebas/archivo_a.txt
echo "/usr/pruebas/archivo_a.txt" > /usr/pruebas/info_archivos.txt
touch /usr/pruebas/archivo_b.txt
chmod 644 /usr/pruebas/archivo_b.txt
echo "/usr/pruebas/archivo_b.txt" >> /usr/pruebas/info_archivos.txt
touch /usr/pruebas/archivo_c.sh
chmod 777 /usr/pruebas/archivo_c.sh
echo "/usr/pruebas/archivo_c.sh" >> /usr/pruebas/info_archivos.txt
touch /usr/pruebas/archivo_d.sh
chmod 544 /usr/pruebas/archivo_d.sh
echo "/usr/pruebas/archivo_d.sh" >> /usr/pruebas/info_archivos.txt

echo "contenido info_archivos.txt"
cat /usr/pruebas/info_archivos.txt

/admin/gpgp.sh /usr/pruebas/info_archivos.txt > /usr/pruebas/perm_archivos.txt

echo "contenido perm_archivos.txt"
cat /usr/pruebas/perm_archivos.txt

chmod 444 /usr/pruebas/archivo_b.txt
chown milax  /usr/pruebas/archivo_d.sh

/admin/rpgp.sh /usr/pruebas/perm_archivos.txt

stat -c "%a %G %U" /usr/pruebas/archivo_a.txt
stat -c "%a %G %U" /usr/pruebas/archivo_b.txt
stat -c "%a %G %U" /usr/pruebas/archivo_c.sh
stat -c "%a %G %U" /usr/pruebas/archivo_d.sh

rm -dR /usr/pruebas

exit 0
