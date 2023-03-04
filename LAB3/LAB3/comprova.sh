#!/bin/bash
# Àngel Gascón Muria
# path absolut: /home/milax/Escriptori/GSX/LAB3
# permisos 755

# Comprobar si el servicio está en ejecución
if ! systemctl is-active --quiet backup.service; then
  echo "El servicio backup no está en ejecución"
  # Puedes insertar aquí acciones adicionales para reiniciar el servicio, por ejemplo:
  echo "Puedes utilizar: {systemctl start backup.service} para encenderlo, una vez hecho puedes usar {systemctl status backup.service} para comprobar que funciona."
  exit 1
fi
echo "El servicio backup está en ejecución, todo ok"

# Obtener el usuario que está ejecutando el proceso asociado al servicio
USER=$(ps -o user= -p $(systemctl show -p MainPID backup.service | awk -F= '{print $2}'))
echo "El usuario ejecutando el servicio es: $USER"

# Comprobar que el proceso está asignado al grupo de cgroups "servidors"
if ! cat /proc/$(systemctl show -p MainPID backup.service | awk -F= '{print $2}')/cgroup | grep -q 'servidors'; then
  echo "El proceso asociado al servicio no está asignado al grupo de cgroups 'servidors'"
  echo "Se recomienda comprobar: sudo mkdir /sys/fs/cgroup/cpu/servidors y sudo mkdir /sys/fs/cgroup/memory/servidors"
  echo "Si ya se han creado los directorios asegurar que el servicio es ejecutado así: {ExecStart=cgexec -g memory,cpu:servidors /usr/bin/myback}"
  exit 1
fi
echo "El proceso asociado al servicio está asignado al grupo de cgroups 'servidors', todo ok"

# Comprobar que el proceso está limitado por el límite de memoria, CPU y número de procesos establecidos por el grupo de cgroups
mem_limit=$(cgget -nvr memory.limit_in_bytes servidors)
if [ $mem_limit -eq 2147483648 ]; then
  echo "El límite de memoria establecido es de 2 GB, todo ok"
else
  echo "El límite de memoria establecido no es de 2 GB."
  echo "Puedes utilizar: echo 2G > /sys/fs/cgroup/memory/servidors/memory.limit_in_bytes"
  exit 1
fi

cpu_period=$(cgget -nvr cpu.cfs_period_us servidors)
if [ $cpu_period -eq 100000 ]; then
  echo "El límite del periodo de la cpu establecido es de 100 ms, todo ok"
else
  echo "El límite del periodo de la cpu establecido no es de 100 ms."
  echo "Puedes utilizar: echo 100000 > /sys/fs/cgroup/cpu/servidors/cpu.cfs_period_us"
  exit 1
fi

cpu_quota=$(cgget -nvr cpu.cfs_quota_us servidors)
if [ $cpu_quota -eq 75000 ]; then
  echo "El límite de quota de la cpu establecido es de 75%, todo ok"
else
  echo "El límite de quota de la cpu establecido no es de 75%."
  echo "Puedes utilizar: echo 75000 > /sys/fs/cgroup/cpu/servidors/cpu.cfs_quota_us"
  exit 1
fi

echo "PIDs asociados al cgroup servidors:"
echo "$(cat /sys/fs/cgroup/cpu/servidors/cgroup.procs)"
echo "Status servicio:"
echo "$(systemctl status backup.service)"

# Si no hay ninguna anomalía, mostrar un mensaje de éxito
echo "El servicio backup está en ejecución correctamente"
