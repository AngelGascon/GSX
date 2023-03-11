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
