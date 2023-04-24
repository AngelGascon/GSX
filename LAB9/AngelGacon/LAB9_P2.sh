#Pregunta2

#Executar el script de creació d'usuaris en ambdues màquines Debian per a crear els mateixos usuaris en ambdues màquines.
#Per a facilitar-me la vida he modificat la configuració de xarxa de la VM a adapatador de red en comptes de NIC, assignant així una ip a les màquines virtuals.

#Configurar el servidor NFS. (Màquina virtual2) Això es pot fer instal·lant el paquet nfs-kernel-server amb la comanda apt-get install nfs-kernel-server. 
#Després, s'ha de crear un directori que es vol compartir, per exemple, /home/nfs amb la comanda mkdir /home/nfs. 
#A continuació, s'ha de configurar el servidor NFS perquè comparteixi el directori que acabem de crear afegint la següent línia al fitxer /etc/exports: /home/nfs *(rw,sync,no_subtree_check)
apt-get install nfs-kernel-server
mkdir -p /empresa/usuaris/departaments
chmod -rw /empresa/usuaris/departaments  #si no s'afegeixen el client no reconeix
echo "/empresa/usuaris/departaments 192.168.1.0/24(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -av
systemctl restart nfs-kernel-server
touch /empresa/usuaris/departaments/hi.txt
echo "Heyy" >> /empresa/usuaris/departaments/hi.txt

#ip addr -> 192.168.1.61 (adreça servidor)

#Configurar el client NFS. (Màquina virtual2) Això es pot fer instal·lant el paquet nfs-common amb la comanda sudo apt-get install nfs-common.
#Després, s'ha de crear un directori en el client on es muntarà el directori compartit del servidor, per exemple, /home/nfs-client amb la comanda sudo mkdir /home/nfs-client.
#A continuació, es pot muntar el directori compartit del servidor amb la comanda: sudo mount -t nfs <ip_del_servidor>:/home/nfs /home/nfs-client
apt-get install nfs-common
mkdir -p /home/nfs-client
mount -t nfs 192.168.1.61:/empresa/usuaris/departaments /home/nfs-client