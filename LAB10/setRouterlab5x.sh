#!/bin/bash
#autor: Àngel Gascón.

# Comprovar si els paquets bind9, bind9-doc i dnsutils estan instal·lats
if ! dpkg -s bind9 bind9-doc dnsutils >/dev/null 2>&1; then
    # Instal·lar els paquets bind9, bind9-doc i dnsutils
    apt update
    apt install bind9 bind9-doc dnsutils
fi

#zona gsx.gei per a 203.0.113.58 amb /27 i zona gsx.int per a 192.168.58.18 amb /25
#vim /etc/bind/named.conf.local
truncate -s 0 /etc/bind/named.conf.local
echo 'zone "gsx.int" {
    type master;
    file "/etc/bind/db.gsx.int";
};

zone "gsx.gei" {
    type master;
    file "/etc/bind/db.gsx.gei";
};

zone "168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168";
};

zone "113.0.203.in-addr.arpa" {
    type master;
    file "/etc/bind/db.203.0.113";
};' >> /etc/bind/named.conf.local

#setejem dbs
touch /etc/bind/db.gsx.gei
truncate -s 0 /etc/bind/db.gsx.gei
chown bind:bind /etc/bind/db.gsx.gei
chmod 755 /etc/bind/db.gsx.gei
echo '$TTL    604800
@       IN      SOA     ns.gsx.gei. root.ns.gsx.gei. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.gsx.gei.
ns      IN      A       203.0.113.33
        IN      MX  10  mail.gsx.gei.
dhcp    IN      CNAME   ns
router  IN      CNAME   ns
ldap    IN      A       203.0.113.62
www     IN      CNAME   ldap
mail    IN      A       203.0.113.62
smtp    IN      CNAME   mail
pop     IN      CNAME   mail' >> /etc/bind/db.gsx.gei

touch /etc/bind/db.gsx.int
truncate -s 0 /etc/bind/db.gsx.int
chown bind:bind /etc/bind/db.gsx.int
chmod 755 /etc/bind/db.gsx.int
echo '$TTL    604800
@       IN      SOA     ns.gsx.int. root.ns.gsx.int. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.gsx.int.
ns      IN      A       192.168.58.1
dhcp    IN      CNAME   ns
router  IN      CNAME   ns
admin   IN      A       192.168.58.126
pc1     IN      A       192.168.58.2
pc2     IN      A       192.168.58.3
pc3     IN      A       192.168.58.4
pc4     IN      A       192.168.58.5
pc5     IN      A       192.168.58.6
pc6     IN      A       192.168.58.7
pc7     IN      A       192.168.58.8
pc8     IN      A       192.168.58.9
pc9     IN      A       192.168.58.10
pc10    IN      A       192.168.58.11
pc11    IN      A       192.168.58.12
pc12    IN      A       192.168.58.13
pc13    IN      A       192.168.58.14
pc14    IN      A       192.168.58.15
pc15    IN      A       192.168.58.16' >> /etc/bind/db.gsx.int

touch /etc/bind/db.203.0.113
truncate -s 0 /etc/bind/db.203.0.113
chown bind:bind /etc/bind/db.203.0.113
chmod 755 /etc/bind/db.203.0.113
echo '$TTL    604800
@       IN      SOA     ns.gsx.gei. root.ns.gsx.gei. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.gsx.gei.
33      IN      PTR     ns.gsx.gei.
62      IN      PTR     mail.gsx.gei.
62      IN      PTR     ldap.gsx.gei.' >> /etc/bind/db.203.0.113


touch /etc/bind/db.192.168
truncate -s 0 /etc/bind/db.192.168
chown bind:bind /etc/bind/db.192.168
chmod 755 /etc/bind/db.192.168
echo '$TTL    604800
@       IN      SOA     ns.gsx.int. root.ns.gsx.int. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.gsx.int.
1.58    IN      PTR     ns.gsx.int.
2.58    IN      PTR     pc1.gsx.int.
3.58    IN      PTR     pc2.gsx.int.
4.58    IN      PTR     pc3.gsx.int.
5.58    IN      PTR     pc4.gsx.int.
6.58    IN      PTR     pc5.gsx.int.
7.58    IN      PTR     pc6.gsx.int.
8.58    IN      PTR     pc7.gsx.int.
9.58    IN      PTR     pc8.gsx.int.
10.58   IN      PTR     pc9.gsx.int.
11.58   IN      PTR     pc10.gsx.int.
12.58   IN      PTR     pc11.gsx.int.
13.58   IN      PTR     pc12.gsx.int.
14.58   IN      PTR     pc13.gsx.int.
15.58   IN      PTR     pc14.gsx.int.
16.58   IN      PTR     pc15.gsx.int.
126.58  IN      PTR     admin.gsx.int.' >> /etc/bind/db.192.168

# vim /etc/resolv.conf -> nameserver 127.0.0.1

#ISP
ISP_READ=$(grep domain-name-servers /var/lib/dhcp/dhclient.eth0.leases | tail -1 | sed "s/^.*domain-name-servers *//" | tr ',' ';')
truncate -s 0 /etc/bind/named.conf.options
echo 'options {
	directory "/var/cache/bind";
	forwarders {
		127.0.0.1;
		192.168.58.1;		
	};
	dnssec-validation no;
	recursion yes;
	allow-recursion {
		203.0.113.32/27;
		192.168.58.0/25;
	};
	allow-transfer {
		127.0.0.1;
		192.168.58.126;
        192.168.58.1;
	};
	listen-on-v6 { none; };
	listen-on {
		127.0.0.1;
		203.0.113.33;
		192.168.58.1;
	};
};' >> /etc/bind/named.conf.options

# IPv4 (-4)
sed -i 's/OPTIONS=.*/OPTIONS="-4 -u bind"/' /etc/default/named
chown bind:bind /var/cache/bind/
chown bind:bind /etc/bind/named.conf.options
chown bind:bind /etc/bind/named.conf.local

systemctl restart bind9

#Check .conf i zones
named-checkconf -z /etc/bind/named.conf.local
named-checkconf -z /etc/bind/named.conf.options
/sbin/named-checkzone gsx.gei /etc/bind/db.gsx.gei
/sbin/named-checkzone gsx.int /etc/bind/db.gsx.int
/sbin/named-checkzone 192.168.58.1 /etc/bind/db.192.168
/sbin/named-checkzone 203.0.113.33 /etc/bind/db.203.0.113

#############################################################################
iptables -t nat -L
#Totes eren  DNAT al port 53
iptables -t nat -F PREROUTING

#filtre forward
iptables -A FORWARD -p udp --dport 53 -j DROP
iptables -A FORWARD -p tcp --dport 53 -j DROP
#PUNT2
sed -i '$ a\prepend domain-name-servers 192.168.58.1, 203.0.113.33;\nsupersede domain-search "gsx.int", "gsx.gei";' /etc/dhcp/dhclient.conf

#PUNT3
truncate -s 0 /etc/dhcp/dhcpd.conf
echo 'subnet 192.168.58.0 netmask 255.255.255.128 {
        range 192.168.58.2 192.168.58.125;
        option subnet-mask 255.255.255.128;
        option broadcast-address 192.168.58.127;
        option routers 192.168.58.1;
        default-lease-time 28800;
        max-lease-time 86400;
        prepend domain-name-servers 127.0.0.1;
		prepend domain-name-servers 192.168.58.1, 203.0.113.33;
		supersede domain-search "gsx.int", "gsx.gei";
		option domain-name "gsx.int";
} 
subnet 203.0.113.32 netmask 255.255.255.224{ 
        range 203.0.113.34 203.0.113.61; 
        option subnet-mask 255.255.255.224; 
        option broadcast-address 203.0.113.63; 
        option routers 203.0.113.33; 
        default-lease-time 28800; 
        max-lease-time 86400; 
        prepend domain-name-servers 192.168.58.1, 203.0.113.33;
    	supersede domain-search "gsx.gei", "gsx.int";
		option domain-name "gsx.gei";
} 
host server { 
        hardware ethernet 36:a0:46:90:cd:6b; 
        fixed-address 203.0.113.62; 
        max-lease-time -1; 
        default-lease-time -1; 
} 
host admin { 
        hardware ethernet 32:6f:49:d5:b7:db; 
        fixed-address 192.168.58.126; 
        max-lease-time -1; 
        default-lease-time -1; 
}' >> /etc/dhcp/dhcpd.conf

sleep 5s

systemctl restart isc-dhcp-server

ifdown eth0
ifup eth0