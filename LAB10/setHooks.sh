vim /etc/dhcp/dhclient-exit-hooks.d/update-hostname #copia fitxer
chmod +r /etc/dhcp/dhclient-exit-hooks.d/update-hostname
ifdown eth0
ifup eth1
#recorda genera_sortida a admin