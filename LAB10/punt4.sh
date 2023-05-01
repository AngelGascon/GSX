##deletes
truncate -s 0 /etc/bind/named.conf.local
truncate -s 0 /etc/bind/named.conf.options
rm /etc/bind/db.gsx.gei
rm /etc/bind/db.gsx.int
rm /etc/bind/db.203.0.113
rm /etc/bind/db.192.168
##

ifdown eth0

# Edit dhclient.conf to request domain-name and domain-name-servers
sudo sed -i '/request/d' /etc/dhcp/dhclient.conf
sudo tee -a /etc/dhcp/dhclient.conf > /dev/null <<EOT
request domain-name;
request domain-name-servers;
EOT

ifup eth0

#vim /etc/resolv.conf -> 
# nameserver 192.168.1.1
# search gsx.gei gsx.int

vim /etc/dhcp/dhclient-exit-hooks.d/update-hostname
chmod +r /etc/dhcp/dhclient-exit-hooks.d/update-hostname
