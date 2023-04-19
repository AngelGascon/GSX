#!/bin/bash
ifdown eth0
if [[ $(cat /etc/dhcp/dhclient.conf | grep 'interface "eth0" {') != "" ]];
then
echo -e 'interface "eth0" {'
echo -e "\tsend hostname gethostname();"
echo -e "\tsend dhcp-lease-time 604800;"
echo -e "}"
fi
ifup eth0


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
