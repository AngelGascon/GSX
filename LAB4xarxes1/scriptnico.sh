#|empresa
#	|usuaris
#	|	|dept1
#	|	|	|user1
#	|	|	|	|bin
#	|	|	|user2
#	|	|dept2
#	|proyectos
#	|bin


path="/empresa"
if [ $# -lt 2 ]
then
   echo "posa un fitxer d'usuaris de parametre I un altra de pojectes" >&2
   exit
else
	#Salvar bashrc general
	cp -p /etc/skel/.bashrc .

	#Raiz de la empresa
        if [ ! -d $path ];
        then
                mkdir $path
        fi


	#Creación del directorio bin general
        if [ ! -d $path/bin ];
        then
                mkdir -m 1755 $path/bin
        fi

        if [ ! -d /etc/skel/bin ];
        then
                mkdir -m 700 /etc/skel/bin
                mv test.sh /etc/skel/bin/
	fi

        if ! grep -q 'export PATH=$PATH:/etc/skel/bin:./ && umask 077' /etc/skel/.bashrc;
        then
                echo 'export PATH=$PATH:/etc/skel/bin:./ && umask 077' >> /etc/skel/.bashrc 
        fi

	

	#Creacion de usuarios
	if [ ! -d $path/usuaris ];
	then
		mkdir $path/usuaris
	fi

	while read linia
        do
		IFS=$':'
		read dni nom tot <<< $linia

		#Crear departamento
		departament=$(echo $tot | grep -oP '^[0-9]\s\K[a-zA-Z]')
		if ! grep -q $departament /etc/group;
		then
			mkdir $path/usuaris/$departament
			groupadd $departament
		fi

		#Instalar dpkg para encriptar la contraseña
		if ! dpkg-query -W -f='${Status}\n' openssl ;
		then
			apt-get install -y openssl
		fi
		useradd -m -d $path/usuaris/$departament/$dni -p $(openssl passwd -1 $dni) -g $departament $dni
		passwd -e $dni

		projectes=$(echo $tot | grep -oP '^[0-9]\s[a-zA-Z]\s\K.*')

		proyectos_usuarios="$proyectos_usuarios\n$dni-$projectes"
	done < $1

        #Crear estructura de los proyectos
        if [ ! -d $path/projectes ];
	then
		mkdir $path/projectes
	fi
	while read proyectos
        do
		IFS=$':'
		read proyecto director <<< $proyectos
		director=$(echo $director | grep -oP '[A-Z]*[0-9]+[A-Z]')
		if ! grep -q $proyecto /etc/group;
                then
                        groupadd $proyecto
                fi
		mkdir $path/projectes/$proyecto
		chown $director:$proyecto $path/projectes/$proyecto
	done < $2

	#Asignar grupos secundarios a los usuarios
	while read linea
	do
		IFS=$':'
		read dni telefono tot <<< $linea
		projectes=$(echo $tot | grep -oP '^[0-9]\s[a-zA-Z]\s\K.*')
		usermod -aG $projectes $dni
	done < $1

	cp -p .bashrc /etc/skel/
	rm .bashrc
fi