#!/bin/bash

# Check if GSX folder has been created successfully
if [ -d "GSX" ]; then
    echo "La carpeta GSX creada amb èxit"
else
    echo "Error: la carpeta GSX no s'ha creat"
fi

# Check if LAB0 and JP0 folders have been created within GSX folder
if [ -d "GSX/LAB0" -a -d "GSX/JP0" ]; then
    echo "Les carpetes GSX/LAB0 i GSX/JP0 s'han creat amb èxit dins de GSX"
else
    echo "Error: la carpeta GSX/LAB0 i/o la carpeta GSX/JP0 no s'ha creat dins de GSX"
fi

# Check if alumne.txt file has been created within LAB0 folder
if [ -f "GSX/LAB0/alumne.txt" ]; then
    echo "El document alumne.txt s'ha creat amb èxit dins de LAB0"
else
    echo "Error: el document alumne.txt no s'ha creat dins de LAB0"
fi

# Check if the contents of alumne.txt file is correct
if [ "$(cat GSX/LAB0/alumne.txt)" = "angel.gascon@estudiants.urv.cat" ]; then
    echo "El contingut de alumne.txt és correcte"
else
    echo "Error: el contingut de alumne.txt és incorrecte"
fi