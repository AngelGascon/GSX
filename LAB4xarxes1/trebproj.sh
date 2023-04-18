#!/bin/bash
#autor: Àngel Gascón

function ajuda() {
  echo "Uso: $0 [opciones] nombre_proyecto"
  echo ""
  echo "Opciones:"
  echo "  -h, --help                Muestra esta ayuda y sale."
  echo ""
  echo "Este script permite entrar en un entorno de proyecto determinado."
}

#comprovem help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  ajuda
  exit 0
fi

#comprovem que el script s'hagi executat amb arguments
if [[ "$#" -lt 1 ]]; then
  echo "Error: Número d'arguments incorrecte."
  echo "Ús: $0 nom_projecte"
  exit 1
fi

proj=$1

#comprovem que el grup i la carpeta del projecte existeixen
if ! grep -q ^$proj: /etc/group || [[ ! -d /empresa/projectes/$proj ]]; then
  echo "Error: No s'ha trobat el grup o la carpeta del projecte."
  exit 1
fi

#Obtenim el nom de l'usuari actual
usuari=$(whoami)

#Obtenim el grup principal de l'usuari actual
grup=$(id -gn)

#Afegim treballador que executa al grup del projecte
if ! usermod -aG "$proj" "$usuari"; then
  echo "Error: No s'ha pogut afegir el treballador al grup del projecte."
  exit 1
fi

#Canviem el directori del treballador a la carpeta del projecte
if ! cd "/empresa/projectes/$proj"; then
  echo "Error: No s'ha pogut accedir a la carpeta del projecte."
  exit 1
fi

#Modifiquem els permisos del directori
if ! chmod g+s .; then
  echo "Error: No s'han pogut modificar els permisos del directori."
  exit 1
fi

#Modifiquem el grup actiu del treballador al del projecte
if ! newgrp "$proj"; then
  echo "Error: No s'ha pogut canviar el grup actiu del treballador."
  exit 1
fi

#init
start_time=$(date +%s)

#Executem entorn del projecte
"$SHELL"

#end
end_time=$(date +%s)

#temps real
echo "Temps real al projecte: $((end_time - start_time)) segons."

#tornem al grup actiu anterior
if ! newgrp "$grup"; then
  echo "Error: No s'ha pogut tornar al grup actiu anterior."
  exit 1
fi

exit 0