#!/usr/bin/bash

FICHIER_ENTREE=$1
FICHIER_SORTIE=$2

# Nettoyer et transformer le texte
cat "$FICHIER_ENTREE" | \
sed 's/\./ \.\n\n/g' | \
sed 's/,/ ,/g' | \
sed 's/;/ ;/g' | \
sed 's/:/ :/g' | \
sed 's/\^/ \^/g' | \
sed 's/(/ (/g' | \
sed 's/)/ )/g' | \
sed 's/[/ [/g' | \
sed 's/]/ ]/g' | \
sed 's/?/ ?\n\n/g' | \
sed 's/!/ !\n\n/g' | \
sed 's/[[:space:]]\+/ /g' | \
sed "s/'/ '\n/g" | \
sed 's/ /\n/g' > "$FICHIER_SORTIE"

#echo "Le fichier $FICHIER_ENTREE a bien été nettoyé et transformé."
