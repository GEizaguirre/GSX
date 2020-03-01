#! /bin/bash

#
# Script con ejecuciones de prueba del servicio snmp.
#

echo "Pruebas con localhost: " > results_snmp.txt
echo "$ snmpstatus -v 2c -c secret14 localhost " >> results_snmp.txt
snmpstatus -v 2c -c secret14 localhost >> results_snmp.txt
echo "$ snmpwalk -v 2c -c secret14 localhost .1.3.6.1.2.1 " >> results_snmp.txt
snmpwalk -v 2c -c secret14 localhost .1.3.6.1.2.1 >> results_snmp.txt
echo "$ snmpwalk -v 2c -c secret14 localhost ucdavis.dskTable.0 " >> results_snmp.txt
snmpwalk -v 2c -c secret14 localhost ucdavis.dskTable.1 >> results_snmp.txt
echo "$ snmptable -v 2c -c secret14 localhost UCD-SNMP-MIB::prTable " >> results_snmp.txt
snmptable -v 2c -c secret14 localhost UCD-SNMP-MIB::prTable >> results_snmp.txt
echo "$ snmptable -v 2c -c secret14 localhost ucdavis.dskTable " >> results_snmp.txt
snmptable -v 2c -c secret14 localhost ucdavis.dskTable >> results_snmp.txt
echo "$ snmptable -v 2c -c secret14 localhost ucdavis.laTable " >> results_snmp.txt
snmptable -v 2c -c secret14 localhost ucdavis.laTable >> results_snmp.txt
echo "$ snmpget -v3 -u gsxViewer -l auth -a SHA -A \"autent14\" 198.18.14.19 system.sysDescr.0" >> results_snmp.txt
snmpget -v3 -u gsxViewer -l auth -a SHA -A "autent14" 198.18.14.19 system.sysDescr.0 >> results_snmp.txt
echo "$ snmpget -v3 -u gsxViewer -l auth -a SHA -A \"auejkel14\" 198.18.14.19 system.sysDescr.0" >> results_snmp.txt
snmpget -v3 -u gsxViewer -l auth -a SHA -A "auejkel14" 198.18.14.19 system.sysDescr.0 >> results_snmp.txt 2>> results_snmp.txt
echo "$ snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A \"autent14\" -x DES -X \"secret14\" 198.18.14.19 system.sysDescr.0" >> results_snmp.txt
snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A "autent14" -x DES -X "secret14" 198.18.14.19 system.sysDescr.0 >> results_snmp.txt
echo "$ snmpget -v3 -u gsxAdmin -l auth -a SHA -A \"autent14\" -x DES -X \"secret14\" 198.18.14.19 system.sysDescr.0" >> results_snmp.txt
snmpget -v3 -u gsxAdmin -l auth -a SHA -A "autent14" -x DES -X "secret14" 198.18.14.19 system.sysDescr.0 >> results_snmp.txt 2>> results_snmp.txt

exit 0
