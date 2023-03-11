#!/bin/bash
# Autor: Àngel Gascon Muria

# Comprova i assigna adreça ip i default gateway a /etc/network/interfaces
if ! grep -q "iface eth0 inet static" /etc/network/interfaces ; then
  ifdown eth0
  sed -i '$d' /etc/network/interfaces
  echo "iface eth0 inet static" >> /etc/network/interfaces
  echo "     address 203.0.113.62/27" >> /etc/network/interfaces
  echo "     gateway 203.0.113.33" >> /etc/network/interfaces
  ifup eth0
fi

if ! grep -q "203.0.113.33       router" /etc/hosts ; then
  echo "203.0.113.33       router" >> /etc/hosts
fi

if ! dpkg -s openssh-server &> /dev/null ; then
  apt install -y openssh-server
fi

if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config ; then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  service ssh restart
fi
