#!/bin/bash
#Nicolas Vanegas Herrera.
#Fecha:10-03-2023
#Version:v1.0
#Explicación Script:Configura la red de un servidor usando el paquete ifupdown.

#Configuracion de la red del servidor usando DHCP.
ifdown eth0
ifup eth0

#Agregar router al fichero de hosts
if [[ $(cat /etc/hosts | grep -oP '[\d.]*\s+\Krouter$') != "router" ]];
then
echo -e '203.0.113.33\trouter' >> /etc/hosts
fi



#Instalar el paquete ssh en caso de no tenerlo.
if ! dpkg-query -W -f='${Status}\n' openssh-server ;
then
apt-get install openssh-server
systemctl restart ssh
fi

if [[ $(cat /etc/ssh/sshd_config | grep -P '^PermitRootLogin\s+.*') == "" ]];
then
echo -e 'PermitRootLogin\tyes' >> /etc/ssh/sshd_config
systemctl restart ssh
fi

exit 0
