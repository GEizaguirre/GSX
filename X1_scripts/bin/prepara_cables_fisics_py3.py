#!/usr/bin/env python3
# coding=UTF-8
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4 foldmethod=marker

# Autor: Josep M. Banus
# Descripcio:
#   Donat un PC amb 3 ethernets, una connectada a la xarxa dels laboratoris,
#   genera un fitxer amb el noms de les interficies i les seves macs.
#   Aquest fitxer haura de ser inclos en la resta d'sripts de configuracio.
# Objectiu: la portabilitat d'un PC a un altre.
# Parametres: cap
# Alternatives: quina_interficie*.sh
# Versio:   2.1

import sys
import os, shutil
import re

entorngrafic= True
try:
    import tkinter
    import tkinter.messagebox
except ImportError:
    entorngrafic= False

# VARS GLOBALS
fitxer= None
# fitxer resultant:
definicions="def_interficies.sh"

# FUNCIONS

# sortida text (vbox) o grafica (labs)
entorngrafic= entorngrafic & ("DISPLAY" in os.environ)
def mostra(titol,missatge):
    if entorngrafic:
        tkinter.messagebox.showinfo(titol,missatge)
    else:
        print(titol+": "+missatge)
        input("\n[Enter]\n")

def mostraError(titol,missatge):
    if entorngrafic:
        tkinter.messagebox.showerror(titol,missatge)
    else:
        print(titol+": "+missatge)
        input("\n[Enter]\n")

def mostraQuestio(titol,missatge):
    if entorngrafic:
        resposta= tkinter.messagebox.askquestion(titol,missatge, icon='warning')
    else:
        print(titol+": "+missatge)
        resposta='si'
        resp= input("\n(S/n)? ")
        if resp in "nN":
            resposta='no'
    return resposta

def getAllInterfaces():
    l= os.listdir('/sys/class/net/')
    # eliminar vlans
    for dev in l:
        if re.match(".*[^0-9a-zA-Z].*",dev):
            l.remove(dev)
    return l

def getPhysicalInterfaces():
    l=[]
    ret=os.system("ls -l /sys/class/net/ | grep '^l' | grep -v virtual | awk '{ print $9 }' >/tmp/if_list.txt")
    with open("/tmp/if_list.txt") as f:
        for dev in f:
            l.append(dev.strip())
    os.remove("/tmp/if_list.txt")
    return l

def getDisconnected(lintf):
    discon=[]
    for intf in lintf:
        dis= os.popen('ip address show '+intf+' | grep -c "\<NO-CARRIER\>"').read().rstrip('\n')
        if dis == '1':
            discon.append(intf)
    return discon 

# si no estan UP no mostren el NO-CARRIER
def prepareDisconnected(lintf):
    socroot= os.environ['USER'] == 'root'
    for intf in lintf:
#        isup= os.popen('ip address show '+intf+' | grep -c "\(state\|status\) UP"').read().rstrip('\n')
        isup= os.popen('ip address show '+intf+' | grep -c "UP"').read().rstrip('\n')
        if isup != '1':
            if socroot:
                os.popen('ip link set '+intf+' up')
            else:
                mostraError("Error", "has de ser root \n\n" +\
                        "(o abans posar totes les interficies del router UP)")
                fracas()

def obreConfiguracio():
    global fitxer
    resposta=mode='w'
    if os.path.isfile(definicions):
        resposta= mostraQuestio("COMPTA","EL fitxer de configuracio ja existeix.\n\n Vols sobreescriure'l? (YES) \n\no afegir al final del fitxer (NO)")
    if resposta=='no':
            mode='a'
    try:
        fitxer = open(definicions, mode)
    except IOError as e:
            mostraError("Error", e.args[1])
            sys.exit(0)
    return mode

def tancaConfiguracio():
    global fitxer
    if fitxer == None:
        return
    if fitxer.closed:
        return
    try:
        fitxer.close()
    except IOError as e:
            mostraError("Error", e.args[1])
            print("Error %d: %s" % (e.args[0],e.args[1]))
            sys.exit(0)

def fracas():
    tancaConfiguracio()
    sys.exit(0)

def main():
    global fitxer,definicions

    mostra("Inici","Ajudo a identificar els noms de les interficies, les seves MACs i cap a on es connectaran.\n\n" +\
           "El resultat es guardara al fitxer\n\t"+definicions +\
           "\nel qual haureu d'importar als vostres scripts.\n")
    mostra("Inici","Prepara els cables:\nAl ROUTER sols hi ha d'haver connectat el que surt cap a Internet.\n\n")
    mostra("Pas 0", "A les ALTRES maquines has de :\n" +\
            "- desconnectar el cable que va a Internet\n" +\
            "- connectar-hi el cable curt.\n" +\
            "- posar la interficie UP:\n    sudo ip link set INTF up.\n\n" +\
            "Despres segueix les instruccions, connectant al ROUTER els cables d'un en un conforme us ho anem demanant.\n\n")

    lintf= getPhysicalInterfaces()
    if len(lintf) == 0:
        mostraError("Error", "Error: no hi ha cap interficie !")
        fracas()

    # ISP: la interficie ja connectada es la sortida cap a Internet

    sortida= os.popen('ip route | grep -i default | head -1').read().split("dev ")[1].split(" ")[0]
    if len(sortida) ==0:
            mostraError("Error:", "no hi ha configurada la sortida cap al default gateway")
            print(os.popen('ip route'))
            fracas()

    mac0= os.popen('ip addr show '+sortida+' | grep "^ *\<link\>" | awk \'{ print $2 }\'').read().strip()

    mode= obreConfiguracio()

    if mode == "w":
        mostra("Info","Sortida cap al ISP per "+sortida)
        fitxer.write("#!/bin/sh\n\n")
        fitxer.write("IFISP=\""+sortida+"\"\n")
        fitxer.write("MacIfISP=\""+mac0+"\"\n\n")

    prepareDisconnected(lintf)
    lDiscInici= getDisconnected(lintf)
    if len(lDiscInici) == 0:
        mostraError("Error:", "no hi ha cap cable desconnectat")
        fracas()

    # primer cable: DMZ
    mostraError("PAS 1", "Desconnectats:\n"+"\n".join(lDiscInici) +\
            "\n\nConnecta el cable de la DMZ.\n\n" +\
            "\n\nAssegura't que els LEDs s'activen" +\
            "\n(sino, mou el cable i/o canvia'l)" +\
            "\n\nEnter quan estiguis ...")

    lDiscPas1= getDisconnected(lintf)

    quin= list(set(lDiscInici) ^ set(lDiscPas1)) # les diferencies
    if len(quin) != 1:
        mostra("Error:", "no has canviat un sol cable\n\nSeguim amb el seguent.")
#        fracas()
    else:
        mostra("Info", "has connectat: "+quin[0])

        mac1= os.popen('ip addr show '+quin[0]+' | grep "^ *\<link\>" | awk \'{ print $2 }\'').read().strip()

        fitxer.write("IFDMZ=\""+quin[0]+"\"\n")
        fitxer.write("MacIfDMZ=\""+mac1+"\"\n\n")

    mostraError("PAS 2", "Desconnectats:\n"+"\n".join(lDiscPas1) +\
            "\n\nConnecta el cable de la INTRANET.\n\n Enter quan estiguis ...")

    lDiscPas2= getDisconnected(lintf)
    # segurament sigui la darrera i no en quedi cap

    quin= list(set(lDiscPas1) ^ set(lDiscPas2)) # les diferencies
    if len(quin) != 1:
        mostraError("Error:", "no has canviat un sol cable")
#        fracas()
    else:
        mostra("Info", "has connectat: "+quin[0])

        mac2= os.popen('ip addr show '+quin[0]+' | grep "^ *\<link\>" | awk \'{ print $2 }\'').read().strip()

        fitxer.write("IFINT=\""+quin[0]+"\"\n")
        fitxer.write("MacIfINT=\""+mac2+"\"\n\n")

    fitxer.close()
    os.chmod(definicions, 0o700)
    shutil.chown(definicions, user='milax', group='milax')
    print()
    print("Resultat:")
    os.system("ls -l "+definicions)
    with open(definicions) as f:
        for line in f:
            print(line, end=' ')
    print()

main()
sys.exit(1)
