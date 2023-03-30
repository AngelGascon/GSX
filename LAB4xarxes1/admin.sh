#!/bin/bash
# Autor: Àngel Gascon Muria

# Comprova i assigna adreça ip i default gateway a /etc/network/interfaces
if ! grep -q "iface eth0 inet static" /etc/network/interfaces ; then
  ifdown eth0
  sed -i '$d' /etc/network/interfaces
  echo "iface eth0 inet static" >> /etc/network/interfaces
  echo "     address 192.168.58.126/25" >> /etc/network/interfaces
  echo "     gateway 192.168.58.1" >> /etc/network/interfaces
  ifup eth0
fi

if ! grep -q "192.168.58.1       router" /etc/hosts ; then
  echo "192.168.58.1       router" >> /etc/hosts
fi

if ! dpkg -s openssh-server &> /dev/null ; then
  apt install -y openssh-server
fi

if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config ; then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  service ssh restart
fi