#!/bin/bash
#autor: Àngel Gascón.

# Constant de màxim número de pings permesos
max_pings=10

# Realitzar la consulta SNMP per obtenir el número de pings rebuts
result=$(snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A aut47861858P -x DES -X secP85816874 router icmpMsgStatsInPkts.ipv4.8)

# Extreure el número de pings del resultat
npings=$(echo $result | awk '{print $NF}')

# Verificar si el número de pings rebuts supera la constant màxima
if [ "$npings" -gt "$max_pings" ]; then
  # Si el número de pings rebuts supera la constant màxima, registrar un avís al log
  logger -p user.warning -t GSX "AVÍS: nombre de pings al router $npings és massa alt"
fi