#!/bin/bash
# Autor: Àngel Gascon Muria

# Comprueba que el usuario milax forme parte del grupo docker
if ! id milax | grep -q "docker";then
    echo "usuario milax no forma parte del grupo docker"
    exit 1
fi

# Comprobar si Docker está activo
if systemctl is-active docker > /dev/null ; then
    # Detener el servicio Docker
    systemctl stop docker
    echo "Servicio Docker detenido"
else
    echo "El servicio Docker no está activo"
fi

# Verificar que el bridge "docker0" existe
if ip link show docker0 > /dev/null 2>&1 ; then
    # Detener el bridge
    ip link set docker0 down
    # Eliminar el bridge
    ip link delete docker0
    echo "Bridge virtual docker0 eliminado"
else
    echo "El bridge virtual docker0 no existe"
fi

# Salvar las reglas iptables
iptables-save > saveRules.v4
ip6tables-save > saveRules.v6

# Limpiar las reglas iptables para todas las tablas
iptables -t nat -F
iptables -t filter -F
iptables -t mangle -F

iptables -t nat -X
iptables -t filter -X
iptables -t mangle -X

ip6tables -t nat -F
ip6tables -t filter -F
ip6tables -t mangle -F

ip6tables -t nat -X
ip6tables -t filter -X
ip6tables -t mangle -X

# Deshabilita la manipulacion de iptables por parte del docker
echo '{ "iptables": false }' | tee /etc/docker/daemon.json

# Restart y crea bridge para el docker
systemctl restart docker
docker network create --driver=bridge --subnet=203.0.113.61/27 DMZ

$bridgeDocker=$(ip link | grep br- | cut -d' ' -f2 | cut -d':' -f1)
#$bridgeDocker i lxcbr1
#ip link add <nombre_de_la_interfaz1> type veth peer name <nombre_de_la_interfaz2>
ip link add veth10 type veth peer name veth20

# ip link set <nombre_de_la_interfaz1> master <nombre_del_puente>
ip link set veth10 master $bridgeDocker
ip link set veth20 master lxcbr1

ip link set veth10 up
ip link set veth20 up