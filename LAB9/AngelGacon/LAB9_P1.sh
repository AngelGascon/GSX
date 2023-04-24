# Pregunta1
# Crea disc virtual i afegeix: GSXDiscBuit.pdf
apt-get install fdisk
apt-get install quota
fdisk -l
#########
#Disk /dev/sda: 48,8 GiB, 52428800000 bytes, 102400000 sectors
#Disk model: VBOX HARDDISK   
#Units: sectors of 1 * 512 = 512 bytes
#Sector size (logical/physical): 512 bytes / 512 bytes
#I/O size (minimum/optimal): 512 bytes / 512 bytes
#Disklabel type: dos
#Disk identifier: 0x82e1d368

#Dispositiu Arrencada     Start     Final   Sectors  Size Id Tipus
#/dev/sda1  *              2048 100399103 100397056 47,9G 83 Linux
#/dev/sda2            100401150 102397951   1996802  975M  5 Estesa
#/dev/sda5            100401152 102397951   1996800  975M 82 Intercanvi Linux / S


#Disk /dev/sdb: 2 GiB, 2147483648 bytes, 4194304 sectors
#Disk model: VBOX HARDDISK   
#Units: sectors of 1 * 512 = 512 bytes
#Sector size (logical/physical): 512 bytes / 512 bytes
#I/O size (minimum/optimal): 512 bytes / 512 bytes
#########

# creem partició /dev/sdb1 i la formategem:
fdisk /dev/sdb
#########
#Welcome to fdisk (util-linux 2.33.1).
#Changes will remain in memory only, until you decide to write them.
#Be careful before using the write command.
#
#Device does not contain a recognized partition table.
#Created a new DOS disklabel with disk identifier 0x2e2ee54a.
#
#Ordre (m per a obtenir ajuda): n
#Partition type
#   p   primary (0 primary, 0 extended, 4 free)
#   e   extended (container for logical partitions)
#Select (default p): p
#Nombre de partició (1-4, default 1): 1
#First sector (2048-4194303, default 2048): 
#Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-4194303, default 4194303): 

#Created a new partition 1 of type 'Linux' and of size 2 GiB.

#Ordre (m per a obtenir ajuda): w
#The partition table has been altered.
#Calling ioctl() to re-read partition table.
#Syncing disks.
#########
mkfs.ext4 /dev/sdb1
#########Creem punt de muntatge i muntem la partició
mkdir /mnt/disc2
mount -t ext4 -o rw,grpquota /dev/sdb1 /mnt/disc2
#########Verifiquem que el disc s'hagi muntat bé
#S. fitxers      Mida En ús Lliure  %Ús Muntat a
#udev            2,0G     0   2,0G   0% /dev
#tmpfs           395M  5,7M   390M   2% /run
#/dev/sda1        47G   22G    23G  49% /
#tmpfs           2,0G     0   2,0G   0% /dev/shm
#tmpfs           5,0M  4,0K   5,0M   1% /run/lock
#tmpfs           2,0G     0   2,0G   0% /sys/fs/cgroup
#tmpfs           395M   12K   395M   1% /run/user/1000
#/dev/sdb1       2,0G  6,0M   1,9G   1% /mnt/disc2
##########
#Copia directori /empresa/projectes a la partició
cp -r /empresa/projecte/ /mnt/disc2/
blkid   #per a saber la UUID de la partició
#modifiquem /etc/fstab/ afegint: UUID /mnt/disc2 ext4 defaults,usrquota,grpquota 0 0
mount -o remount /mnt/disc2 #remount per aplicar els canvis a /etc/fstab/
#Habilita sistema de quotes dins la particio
quotacheck -cug /mnt/disc2
du /mnt/disc2/
##
#16	/mnt/disc2/lost+found
#4	/mnt/disc2/projectes/Raspberry
#4	/mnt/disc2/projectes/Disseny
#4	/mnt/disc2/projectes/Marqueting
#4	/mnt/disc2/projectes/Administracio
#20	/mnt/disc2/projectes
#56	/mnt/disc2/
##
# edquota -g group_name
setquota -g Disseny 10 100 0 0 /mnt/disc2
setquota -g Raspberry 10 100 0 0 /mnt/disc2
setquota -g Marqueting 10 100 0 0 /mnt/disc2
setquota -g Administracio 10 100 0 0 /mnt/disc2
quotaon -ug /mnt/disc2
quota -vg Disseny
#Disk quotas for group Disseny (gid 1002): 
#     Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
#      /dev/sdb1       0      10     100               0       0       0
#/empresa/tmp
mkdir -p /tmp/disc2/empresa/tmp
mount -t tmpfs -o size=100M tmpfs /tmp/disc2/empresa/tmp
chmod a+rwxt /tmp/disc2/empresa/tmp
# drwxrwxrwt -> garanteix que tothom tinngui tots els permissos necessaris sobre els fitxers, però que ningú pugui carregar-se els fitxers d'un altre.