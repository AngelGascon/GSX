#!/bin/bash

# Obtenemos la fecha actual en el formato aammddhhmm
DATE=$(date +%y%m%d%H%M)

# Get directories for users with a shell of /bin/bash
dirs=$(cat /etc/passwd | grep "/bin/bash" | cut -d ':' -f 6)

# Loop over directories and process files
for dir in $dirs; do
    # Check if the aguardar.txt file exists in the directory
    if [ -f "$dir/aguardar.txt" ]; then
        # Create backup file with timestamp and username in /back directory
        user=$(basename "$dir")
        backup_file="/back/$DATE-$user.tgz"
        tar czf "$backup_file" "$dir/aguardar.txt"

        # Change owner and permissions of backup file
        chown "$user" "$backup_file"
        chmod 400 "$backup_file"
    fi
done
