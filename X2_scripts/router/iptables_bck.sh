
#! /bin/bash

# Script para restaurar las políticas permisivas
# iniciales del cortafuegos del router.

# Eliminar reglas previas.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
