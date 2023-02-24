#!/bin/bash

#Abans de començar es important fer un sudo update per tenir els packages actualitzats

# Check if package names are provided by the user
if [ -z $1 ]; then
  echo "Packages names not provided, nothing to check" >&2
  exit 1
fi

# Iterate through the arguments provided
for package in "$@"; do
  # Check if the package is not installed, otherwise check if package has upgrades
  if ! apt list --installed 2>/dev/null | grep -q "^$package/"; then
    # not installed case
    echo "$(date +'%Y-%m-%d %H:%M:%S'), Package $package is not installed."
  else if ! apt list --upgradable 2>/dev/null | grep -q "^$package/"; then
    # no upgrades case
    echo "$(date +'%Y-%m-%d %H:%M:%S'), Package $package has no upgrades."
  else
    # has upgrades case
    new_version=$(apt list --upgradable 2>/dev/null | grep "\b$package/" | cut -d' ' -f2 | cut -d'/' -f1)
    echo "$(date '+%Y-%m-%d %H:%M:%S'), $package actualitzable a la versió $new_version" | logger
  fi
  fi
done
