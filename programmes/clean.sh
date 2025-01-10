#!/usr/bin/bash

FICHIER_ENTREE=$1
FICHIER_SORTIE=$2

#file $FICHIER_ENTREE

cat "$FICHIER_ENTREE" | \
sed "s/[‘’]/'/g" | \
sed "s/'/ /g" | \
sed "s/…//g" | \
sed "s/[«»]//g" | \
sed 's/\./\.\n\n/g' | \
sed 's/?/?\n\n/g' | \
sed 's/!/!\n\n/g' | \
tr -d '[:punct:]' | \
sed 'y/ÀÂÄÇÈÉÊËÎÏÔÖÙÛÜŸ/àâäçèéêëîïôöùûüÿ/' | \
tr '[:upper:]' '[:lower:]' | \
sed 's/[[:space:]]\+/ /g' > "$FICHIER_SORTIE" 

#echo "Le fichier $FICHIER_ENTREE a bien été nettoyé."
