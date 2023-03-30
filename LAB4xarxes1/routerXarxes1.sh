#!/bin/bash
# Autor: Angel Gascon Muria

#mirem si eth1 esta aixecada
if ip link show eth1 | grep -q "state UP"; then
  echo "Interface eth1 is already up"
else
  echo "Activating eth1"
  ip link set dev eth1 up
fi


#comprovem si la adreça ha estat afegida
if ! ip a | grep -q "inet 203.0.113.33/27 scope global eth1" ; then
  ip addr add 203.0.113.33/27 dev eth1
  echo "Configurada l'adreça IP de la interficie eth1."
fi

#activa forwarding IPv4
sysctl -w net.ipv4.ip_forward=1

#assignem adreça server a /etc/hosts
if ! grep -q "203.0.113.62      server" /etc/hosts ; then
  echo "203.0.113.62      server" >> /etc/hosts
  echo "ip server escrita"
fi

if ! iptables-save -t nat | grep -q "203.0.113.32/27.*MASQUERADE"; then
  iptables -t nat -A POSTROUTING -s 203.0.113.62/27 -o eth0 -j MASQUERADE
fi

#checkeja si el paquet ssh es instal·lat, sino l'instal·la
if ! dpkg -s openssh-server &> /dev/null ; then
  apt install -y openssh-server
fi

if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config ; then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  service ssh restart
fi

################DHCP -> intranet: 192.168.58.18 amb /25

#mirem si eth2 esta aixecada
if ip link show eth2 | grep -q "state UP"; then
  echo "Interface eth2 is already up"
else
  echo "Activating eth2"
  ip link set dev eth2 up
fi

#comprovem si la adreça ha estat afegida
if ! ip a | grep -q "inet 192.168.58.1/25 scope global eth2" ; then
  ip addr add 192.168.58.1/25 dev eth2
  echo "Configurada l'adreça IP de la interficie eth2."
fi

if ! iptables-save -t nat | grep -q "192.168.58.0/25.*MASQUERADE"; then
  iptables -t nat -A POSTROUTING -s 192.168.58.1/25 -o eth0 -j MASQUERADE
fi

#comprovem si el servei dhcp està instal·lat
if ! dpkg -s isc-dhcp-server &> /dev/null ; then
  apt install -y isc-dhcp-server
fi

#configurem el fitxer /etc/default/isc-dhcp-server que escolti a la eth1 i eth2
INTERFACES="eth1 eth2"
# Backup del fitxer original /etc/default/isc-dhcp-server
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
# Edita el fitxer per a que escolti a les interfícies eth1 i eth2
sed -i "s/INTERFACESv4=\".*\"/INTERFACESv4=\"$INTERFACES\"/" /etc/default/isc-dhcp-server

# Afegir la subnet DMZ al fitxer de configuració
if ! grep -q "subnet 203.0.113.32 netmask 255.255.255.224" /etc/dhcp/dhcpd.conf ; then
  echo "subnet 203.0.113.32 netmask 255.255.255.224 {" >> /etc/dhcp/dhcpd.conf
  echo "  range 203.0.113.34 203.0.113.61;" >> /etc/dhcp/dhcpd.conf
  echo "  option subnet-mask 255.255.255.224;" >> /etc/dhcp/dhcpd.conf
  echo "  option broadcast-address 203.0.113.63;" >> /etc/dhcp/dhcpd.conf
  echo "  option routers 203.0.113.33;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time 28800;" >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
  echo "  option domain-name-servers 203.0.113.33;" >> /etc/dhcp/dhcpd.conf
  echo "}" >> /etc/dhcp/dhcpd.conf
fi

# Afegir la subnet INTRANET al fitxer de configuració
if ! grep -q "subnet 192.168.58.0 netmask 255.255.255.128" /etc/dhcp/dhcpd.conf ; then
  echo "subnet 192.168.58.0 netmask 255.255.255.128 {" >> /etc/dhcp/dhcpd.conf
  echo "  range 192.168.58.2 192.168.58.125;" >> /etc/dhcp/dhcpd.conf
  echo "  option subnet-mask 255.255.255.128;" >> /etc/dhcp/dhcpd.conf
  echo "  option broadcast-address 192.168.58.127;" >> /etc/dhcp/dhcpd.conf
  echo "  option routers 192.168.58.1;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time 28800;" >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time 86400;" >> /etc/dhcp/dhcpd.conf
  echo "  option domain-name-servers 192.168.58.1;" >> /etc/dhcp/dhcpd.conf
  echo "}" >> /etc/dhcp/dhcpd.conf
fi

# Afegir server al fitxer de configuració
if ! grep -q "host server" /etc/dhcp/dhcpd.conf ; then
  echo "host server {" >> /etc/dhcp/dhcpd.conf
  echo "  hardware ethernet 72:5b:51:ab:db:9f;" >> /etc/dhcp/dhcpd.conf
  echo "  fixed-address 203.0.113.62;" >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time -1;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time -1;" >> /etc/dhcp/dhcpd.conf
  echo "}" >> /etc/dhcp/dhcpd.conf
fi

# Afegir admin al fitxer de configuració
if ! grep -q "host admin" /etc/dhcp/dhcpd.conf ; then
  echo "host admin {" >> /etc/dhcp/dhcpd.conf
  echo "  hardware ethernet 6a:c8:aa:6d:b5:62;" >> /etc/dhcp/dhcpd.conf
  echo "  fixed-address 192.168.58.126;" >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time -1;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time -1;" >> /etc/dhcp/dhcpd.conf
  echo "}" >> /etc/dhcp/dhcpd.conf
fi

# De moment no afegirem cap domini DNS però si que hi posarem que el servidor de noms és el nostre router (sense domini).
if ! grep -q "nameserver 10.0.2.17" /etc/resolv.conf; then 
  echo "nameserver 10.0.2.17" >> /etc/resolv.conf
fi

# Reinicia el servei per aplicar els canvis
systemctl restart isc-dhcp-server