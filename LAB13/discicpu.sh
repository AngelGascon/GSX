#!/bin/bash
#Author: Àngel Gascón Muria

# Comprova si s'ha proporcionat un paràmetre
if [ $# -eq 0 ]; then
  echo "Cal proporcionar el nombre de dies a analitzar com a paràmetre."
  exit 1
fi

# Obté el nombre de dies a analitzar del primer paràmetre
dies=$1

# Filtra els usuaris que han entrat al sistema en els últims X dies
usuaris=$(last -s "-${dies} days" | sort | uniq -w 8 -i | cut -d' ' -f1 | sed '1d;$d')

# Treu per pantalla quants kbytes d’espai de disc ocupa i quants inodes els directoris d'entrada dels usuaris
for usuari in $usuaris; do
    directori=$(grep "$usuari:" /etc/passwd | cut -d':' -f6)
    if [ -d "$directori" ]; then
        espai=$(du -sk "$directori" | cut -f1)
        inodes=$(find "$directori" -type f | wc -l)
        cpu=$(lastcomm --user $usuari | awk '{ sum += $4 } END { printf("%.2f", sum) }')
        echo "$usuari $espai Kbytes $inodes inodes CPU: $cpu segons"
    fi
done