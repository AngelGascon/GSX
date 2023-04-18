#!/bin/bash
#autor: Àngel Gascón

function ajuda() {
  echo "Este script crea usuarios y grupos en el sistema."
  echo "Uso: $0 [archivo_usuarios] [archivo_proyectos]"
  echo "Opciones:"
  echo "  -h, --help        Muestra este mensaje de ayuda"
  echo ""
  echo "El archivo_usuarios debe tener el siguiente formato:"
  echo "dni:nombre:telefono:departamento:proyectos"
  echo ""
  echo "El archivo_proyectos debe tener el siguiente formato:"
  echo "nombre_proyecto:cap:descripcion"
  echo ""
  echo "Ejemplo:"
  echo "$0 usuarios.txt proyectos.txt"
}

#comprovem help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  ajuda
  exit 0
fi

mkdir -p /empresa/bin
#establim l'sticky bit per a que els fitxer tant sols pugin ser esborrats per l'autor, permissos correctes i PATH
chmod 1755 /empresa/bin
export PATH=$PATH:/empresa/bin

#Llegiex params
if [ $# -ne 2 ] 
then
  echo "posa un fitxer d'usuaris de parametre i un fitxer projectes" >&2
  ajuda
  exit
else
  #afegir bin a /etc/skel
  mkdir -p -m 700 /etc/skel/bin
  if ! grep -q 'export PATH=$PATH:/etc/skel/bin:./ && umask 077' /etc/skel/.bashrc; then
    echo 'export PATH=$PATH:/etc/skel/bin:./ && umask 077' >> /etc/skel/.bashrc 
  fi
  #fitxer usuaris
  while read linia 
  do 
    IFS=$':' 
    read dni nom tel dep proj <<< $linia
    if [ "$dni" = "dni" ]; then
      continue
    fi
    mkdir -p /empresa/usuaris/$dep
    if ! grep -q $dep /etc/group; then
      groupadd $dep
    fi
    useradd -m -d /empresa/usuaris/$dep/$dni -g $dep $dni
    passwd -e $dni
  done < $1
  #fitxer projectes
  while read linia2
  do 
    IFS=$':' 
    read nom cap descrip <<< $linia2
    if [ "$nom" = "nom projecte" ]; then
      continue
    fi
    if ! grep -q $nom /etc/group; then
      groupadd $nom
    fi
    mkdir -p /empresa/projectes/$nom
    chown $cap -R /empresa/projectes/$nom
  done < $2
  #grups secundaris
  while read linia3
  do 
    IFS=$':' 
    read dni nom tel dep proj <<< $linia3
    if [ "$dni" = "dni" ]; then
      continue
    fi
    #afegir grups secundaris
    for proj_sep in $(echo $proj | cut -d ',' -f 1-)
    do
      if [ "$proj_sep" != "$dep" ]; then
        usermod -aG $proj_sep $dni
      fi
    done
  done < $1
fi