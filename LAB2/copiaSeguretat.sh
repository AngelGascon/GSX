#!/bin/bash

# Obtenemos la fecha actual en el formato aammddhhmm
DATE=$(date +%y%m%d%H%M)

# Obtenemos el nombre de usuario actual
USER=$(whoami)

# Directorio de backup
BACKUP_DIR="/back"

# Directorio de inicio del usuario
USER_DIR="$HOME"

# Ruta completa al archivo aguardar.txt
GUARDAR_FILE="$USER_DIR/aguardar.txt"

# Comprobamos si el archivo existe
if [ -f "$GUARDAR_FILE" ]; then
  # Creamos el nombre del archivo de backup
  BACKUP_FILE="$BACKUP_DIR/$DATE-$USER.tgz"

  # Obtenemos los nombres de los archivos a incluir en el backup
  FILES=$(cat "$GUARDAR_FILE")

  # Creamos el archivo tgz de backup
  tar czf "$BACKUP_FILE" $FILES

  # Cambiamos los permisos del archivo de backup para que solo el usuario tenga permisos de lectura
  chmod 400 "$BACKUP_FILE"

  echo "Backup realizado con éxito en: $BACKUP_FILE"

else
  echo "El archivo aguardar.txt no existe en $USER_DIR"
fi
