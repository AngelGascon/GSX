#!/bin/bash
### BEGIN INIT INFO
# Provides:       actualizado
# Required-Start: $local_fs $remote_fs $network
# Required-Stop:  $local_fs $remote_fs $network
# Default-Start:  2 3
# Default-Stop:
# Short-Description: Ejecuta el script actualizado.sh si existe /root/paquetes
# Description:     Ejecuta el script actualizado.sh si existe /root/paquetes
### END INIT INFO



# Verificar si existe el archivo /root/paquetes
if [ -f "/root/paquetes" ]
then
    # Leer los parametros desde el archivo
    parametros=$(cat /root/paquetes)
    # Ejecutar el script actualizado.sh con los parametros leidos
    #home/milax/Escriptori/GSX/LAB1/actualitzat.sh $parametros
    home/kali/Desktop/GSX/LAB1/actualitzat.sh $parametros
else
    # Indicar en el archivo de log correspondiente que el archivo no existe - > arxiu de log a /var/log/daemon.log
    echo "El archivo /root/paquetes no existe" >> /var/log/daemon.log
fi
