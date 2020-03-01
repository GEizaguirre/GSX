#! /bin/bash

PATH="$PATH:/home/milax"

test "$HOSTNAME" = "Router" && ( cp router/interfaces.router.bck /etc/network/interfaces; cp router/resolv.conf.router.bck /etc/resolv.conf; echo " Network configuration was reset.")

test "$HOSTNAME" = "Client" && ( cp intern/interfaces.client.bck /etc/network/interfaces; cp intern/resolv.conf.client.bck /etc/resolv.conf; echo " Network configuration was reset.")

test "$HOSTNAME" = "Server" && ( cp server/interfaces.server.bck ietc/network/interfaces; cp server/resolv.conf.server.bck /etc/resolv.conf; echo " Network configuration was reset.")

exit 0
