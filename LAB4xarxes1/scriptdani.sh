#! /bin/bash
# Autor: Daniel Becerra Oliva
# Data: 15/4/2023
# Versió 1.0

# Verifiquem que el script s'hagi executat amb arguments
if [ "$#" -ne 1 ]; then
  echo "Error: Nombre d'arguments incorrecte."
  echo "Ús: $0 nom_projecte"
  exit 1
fi

if ! grep -q ^$1: /etc/group ; then
  echo "No s'ha trobat el grup." >&2
  exit 1
fi

if [[ ! -d /empresa/projectes/$1 ]]; then
  echo "No s'ha trobat el directori." >&2
  exit 1
fi

projecte=$1

# Obtenim el nom de l'usuari actual
usuari=$(whoami)

# Obtenim el grup principal de l'usuari actual
grup=$(id -gn)

# Afegim l'usuari al grup del projecte
usermod -aG "$projecte" "$usuari"

# Canviem el directori d'usuari a la carpeta del projecte
cd "/empresa/projectes/$projecte"

# Modifiquem els permisos del directori perquè els fitxers creats tinguin per defecte permisos pel propietari i pel grup
chmod g+s .

# Modifiquem el grup actiu de l'usuari a la del projecte
newgrp "$projecte"

# Guardem el temps en què hem entrat al projecte
start_time=$(date +%s)

# Executem l'entorn del projecte
"$SHELL"

# Guardem el temps en què hem sortit del projecte
end_time=$(date +%s)

# Mostrem el temps real que hem estat en el projecte
echo "Temps real al projecte: $((end_time - start_time)) segons."

# Tornem al grup actiu anterior
newgrp "$grup"