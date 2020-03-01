#!/bin/bash

echo " Se instalarán bind9, bind9-doc y dnsutils de no estar ya instalados"

dpkg -s bind9 > /var/null
test $? -eq 1 && apt-get install bind9
dpkg -s bind9-doc > /var/null
test $? -eq 1 && apt-get install bind9-doc
dpkg -s dnsutils > /var/null
test $? -eq 1 && apt-get install dnsutils

exit 0
