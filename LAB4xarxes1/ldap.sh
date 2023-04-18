#install paquets OpenLDAP
#dins server:
apt install slapd ldap-utils -y
hostnamectl set-hostname ldap.gsx.gei
#necessari instal·lar per a no rebre error
sudo apt-get install dbus
systemctl restart dbus.service
#
vim /etc/hosts
# afegim: 103.0.113.62      ldap.gsx.gei ldap
dpkg-reconfigure slapd  # afegir configuracio determinada
systemctl restart slapd

nano /etc/ldap/users.ldif   # afegir configuracio determinada
ldapadd -D "cn=admin,dc=gsx,dc=gei" -W -H ldapi:/// -f /etc/ldap/users.ldif
#dn: ou=usuaris,dc=gsx,dc=gei
#objectClass: organizationalUnit
#ou: usuaris

ldapsearch -x -b "dc=gsx,dc=gei" ou
#####################################Output:
# extended LDIF
#
# LDAPv3
# base <dc=gsx,dc=gei> with scope subtree
# filter: (objectclass=*)
# requesting: ou 
#

# gsx.gei
dn: dc=gsx,dc=gei

# usuaris, gsx.gei
dn: ou=usuaris,dc=gsx,dc=gei
ou: usuaris

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
####################################

#Crea usuari
# Add user alice to LDAP Server -> creem alice.ldif
dn: cn=alice,ou=usuaris,dc=gsx,dc=gei
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: alice
uid: alice
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/alice
userPassword: 1234
loginShell: /bin/bash
# Afegir usuari
ldapadd -D "cn=admin,dc=gsx,dc=gei" -W -H ldapi:/// -f alice.ldif
# Check Alice
ldapsearch -x -b "ou=usuaris,dc=gsx,dc=gei"
#################################### Output:
# extended LDIF
#
# LDAPv3
# base <ou=usuaris,dc=gsx,dc=gei> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# usuaris, gsx.gei
dn: ou=usuaris,dc=gsx,dc=gei
objectClass: organizationalUnit
ou: usuaris

# alice, usuaris, gsx.gei
dn: cn=alice,ou=usuaris,dc=gsx,dc=gei
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: alice
uid: alice
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/alice
loginShell: /bin/bash

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
####################################






















#Durant l'install
#    Nombre de dominio LDAP: gsx.gei
#    Nombre de la organización: GSX
#    Contraseña para el administrador de LDAP: [contraseña de su elección]
#    Confirmación de la contraseña del administrador de LDAP: [confirmación de la contraseña]
groupadd usuaris
useradd -m -G usuaris usuario1
useradd -m -G usuaris usuario2
useradd -m -G usuaris usuario3


#dins els clients al arxiu /etc/ldap/ldap.conf cal afegir: (per a poder-se comunicar amb el server)
#BASE    dc=gsx,dc=gei
#URI     ldap://ldap.gsx.gei
apt install libpam-ldap -y
#    Nombre del servidor LDAP: ldap.gsx.gei
#    Nombre de la base de datos: dc=gsx,dc=gei
#    Configurar el uso de Kerberos: No
#    Tipo de backend: Unix
systemctl restart nscd
systemctl restart nslcd
#un cop tot fet iniciar sessio amb les credencials adecuades als clients
su - usuario1
id usuario1