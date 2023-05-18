#!/bin/bash
#autor: Àngel Gascón.

#1
dd if=/dev/zero of=/var/swap bs=4096k count=16
chmod 600 /var/swap
mkswap /var/swap
swapon /var/swap
swapon -s
#whereis swapon -> mostra directoris d'on surten les comandes, usant la variable d'entorn PATH podem confirmar que el swapon no es troba
#posant el path absolut es pot executar com a usuari milax
#al usuari sudo si que es pot executar sense usar el path absolut ja que swapon es troba a la variable d'entorn PATH
lsmod
#descomprimir i copiar memtest86-usb.tgz a l'espai de treball
mount -o loop memtest86-usb.img /mnt

#2
apt install cups -y
apt-get install cups-pdf
#accedir gràficament 127.0.0.1:631 -> admin 
#canvia contrasenya root: sudo su i passwd
#afegir nom: lpVirtual i tipus genèric
#lpVirtual
#lpVirtual (Idle, Accepting Jobs, Not Shared)
#Description:	Virtual PDF Printer
#Location:	lpVirtual a un lloc increible
#Driver:	Generic CUPS-PDF Printer (w/ options) (color)
#Connection:	cups-pdf:/
#Defaults:	job-sheets=none, none media=iso_a4_210x297mm sides=one-sided
vim /etc/cups/cups-pdf.conf
#modifiquem l'entrada Out ${HOME}/PDF per Out ${HOME}/DocsPDF
systemctl restart cups
lp -d lpVirtual hi.txt

#3
#a whereis lp ha de sortir lo de tota la vida i lo nostre, a més se lia ha de donar prio al nostre

#whereis lp
#lp: /usr/bin/lp /usr/local/bin/lp /usr/share/man/man1/lp.1.gz /usr/share/man/man4/lp.4.gz
#echo $PATH
#/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:

#!/bin/bash
#permissos: 755
#path: /usr/local/bin/lp

# Demana la paraula clau
echo "Introdueix la paraula clau:"
stty -echo
read password
stty echo
# Comprova la paraula clau
if [ "$password" != "paraulaclau" ]; then
    echo "Error: la paraula clau introduïda no és correcta."
    exit 1
fi
# Si la paraula clau és correcta, executa lp estàndard
command /usr/bin/lp "$@"
exit 0