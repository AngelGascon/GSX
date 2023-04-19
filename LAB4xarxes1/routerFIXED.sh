#!/bin/bash
#Nicolas Vanegas Herrera.
#Fecha:10-03-2023
#Version:v1.0
#Explicación Script:Configura la red del router usando el paquete iproute2.

#Configurar la interfaz eth1
ip address add 203.0.113.33/27 broadcast \203.0.113.63 dev eth1

#Configurar la interfaz eth2
ip address add 192.168.58.1/25 broadcast \192.168.58.127 dev eth2

#Levantar la eth1
ip link set eth1 up

#Levantar la eth2
ip link set eth2 up

#Activar el fordwarding
sysctl -w net.ipv4.ip_forward=1

#Agregar los host
if [[ $(cat /etc/hosts | grep -oP '[\d.]*\s+\Kserver$') != "server" ]];
then
echo -e '203.0.113.62\tserver' >> /etc/hosts
fi

#Comprobar si esta configurado el POSTROUTING y configurarlo DMZ.
if [[ $(iptables -t nat -n -L | grep -o '203.0.113.32/27') == ""  ]];
then
iptables -t nat  -A POSTROUTING -s 203.0.113.32/27 -o eth0 -j MASQUERADE
fi

#Comprobar si esta configurado el POSTROUTING y configurarlo intranet.
if [[ $(iptables -t nat -n -L | grep -o '192.168.58.0/25') == ""  ]];
then
iptables -t nat  -A POSTROUTING -s 192.168.58.0/25 -o eth0 -j MASQUERADE
fi

#Comprobar si esta configurado el POSTROUTING DNS y configurarlo.
if [[ $(iptables -t nat -n -L | grep -o '192.168.58.1') == ""  ]];
then
iptables -t nat -A PREROUTING -i eth2 -d 192.168.58.1 -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53
iptables -t nat -A PREROUTING -i eth2 -d 192.168.58.1 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8:53
fi

if [[ $(iptables -t nat -n -L | grep -o '203.0.113.33') == ""  ]];
then
iptables -t nat -A PREROUTING -i eth1 -d 203.0.113.33 -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8:53
iptables -t nat -A PREROUTING -i eth1 -d 203.0.113.33 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8:53
fi
#Instalar el paquete ssh en caso de no tenerlo.
if [[ $(dpkg-query -W -f='${Status}\n' openssh-server | grep -oP 'no.*found') != "" ]];
then
apt-get install -y openssh-server
systemctl restart ssh
fi

if [[ $(cat /etc/ssh/sshd_config | grep -P '^PermitRootLogin\s+.*') == "" ]];
then
echo -e 'PermitRootLogin\tyes' >> /etc/ssh/sshd_config
systemctl restart ssh
fi

#Comprobar instalacion del isc-dhcp-server
if ! dpkg-query -W -f='${Status}\n' isc-dhcp-server ;
then
apt-get install -y isc-dhcp-server
fi


if [[ $(cat /etc/default/isc-dhcp-server | grep 'INTERFACESv4=""') != "" ]];
then
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1 eth2"/' /etc/default/isc-dhcp-server
fi

if [[ $(cat /etc/dhcp/dhcpd.conf | grep "subnet 192.168.58.0 netmask 255.255.255.128 {") == "" ]];
then
echo -e "subnet 192.168.58.0 netmask 255.255.255.128 {" >> /etc/dhcp/dhcpd.conf
echo -e "\trange 192.168.58.2 192.168.58.125;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption subnet-mask 255.255.255.128;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption broadcast-address 192.168.58.127;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption routers 192.168.58.1;" >> /etc/dhcp/dhcpd.conf
echo -e "\tdefault-lease-time 28800;" >> /etc/dhcp/dhcpd.conf
echo -e "\tmax-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption domain-name-servers 192.168.58.1;" >> /etc/dhcp/dhcpd.conf
echo -e "}" >> /etc/dhcp/dhcpd.conf
fi

if [[ $(cat /etc/dhcp/dhcpd.conf | grep "subnet 203.0.113.32 netmask 255.255.255.224{") == "" ]];
then
echo -e "subnet 203.0.113.32 netmask 255.255.255.224{" >> /etc/dhcp/dhcpd.conf
echo -e "\trange 203.0.113.34 203.0.113.61;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption subnet-mask 255.255.255.224;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption broadcast-address 203.0.113.63;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption routers 203.0.113.33;" >> /etc/dhcp/dhcpd.conf
echo -e "\tdefault-lease-time 28800;" >> /etc/dhcp/dhcpd.conf
echo -e "\tmax-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
echo -e "\toption domain-name-servers 203.0.113.33;" >> /etc/dhcp/dhcpd.conf
echo -e "}" >> /etc/dhcp/dhcpd.conf
fi
#TODO hardware ethernet eth1
if [[ $(cat /etc/dhcp/dhcpd.conf | grep "host server {") == "" ]];
then
echo -e "host server {" >> /etc/dhcp/dhcpd.conf
echo -e "\thardware ethernet 5e:8b:0b:5e:d6:49;" >> /etc/dhcp/dhcpd.conf
echo -e "\tfixed-address 203.0.113.62;" >> /etc/dhcp/dhcpd.conf
echo -e "\tmax-lease-time -1;" >> /etc/dhcp/dhcpd.conf
echo -e "\tdefault-lease-time -1;" >> /etc/dhcp/dhcpd.conf
echo -e "}" >> /etc/dhcp/dhcpd.conf
fi
#TODO hardware ethernet eth2
if [[ $(cat /etc/dhcp/dhcpd.conf | grep "host admin {") == "" ]] ;
then
echo -e "host admin {" >> /etc/dhcp/dhcpd.conf
echo -e "\thardware ethernet 26:5f:84:57:96:84;" >> /etc/dhcp/dhcpd.conf
echo -e "\tfixed-address 192.168.58.126;" >> /etc/dhcp/dhcpd.conf
echo -e "\tmax-lease-time -1;" >> /etc/dhcp/dhcpd.conf
echo -e "\tdefault-lease-time -1;" >> /etc/dhcp/dhcpd.conf
echo -e "}" >> /etc/dhcp/dhcpd.conf
fi


sleep 20
systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server

exit 0
