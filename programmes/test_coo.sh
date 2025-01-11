#!/bin/bash

LANGUE=$1
MOT1=$2
MOT2=$3
FILE=$4

# Vérification des arguments
if [[ -z "$LANGUE" || -z "$MOT1" ]]; then
    echo "Usage: $0 <LANGUE> <MOT1 ou fichier variantes 1> [MOT2 ou fichier variantes 2] <fichier contexte>"
    exit 1
fi

# Vérification du fichier contexte
if [[ ! -f "$FILE" ]]; then
    echo "Erreur : fichier contexte $FILE introuvable."
    exit 1
fi

# Gestion des variantes pour MOT1
if [[ -f "$MOT1" ]]; then
    VARIANTES1=$(cat "$MOT1" | tr '\n' '|' | sed 's/|$//')
else
    VARIANTES1="$MOT1"
fi

# Gestion des variantes pour MOT2 (si fourni)
if [[ -n "$MOT2" ]]; then
    if [[ -f "$MOT2" ]]; then
        VARIANTES2=$(cat "$MOT2" | tr '\n' '|' | sed 's/|$//')
    else
        VARIANTES2="$MOT2"
    fi
fi

# Construire et exécuter la commande Python pour MOT1
echo "Exécution pour MOT1/VARIANTES1 : $VARIANTES1"
python3 programmes/cooccurrents.py "$FILE" --target "($VARIANTES1)" --match-mode regex > "./cooccurrents-$LANGUE-mot1.txt"

# Construire et exécuter la commande Python pour MOT2 si fourni
if [[ -n "$MOT2" ]]; then
    echo "Exécution pour MOT2/VARIANTES2 : $VARIANTES2"
    python3 programmes/cooccurrents.py "$FILE" --target "($VARIANTES2)" --match-mode regex > "./cooccurrents-$LANGUE-mot2.txt"
fi

echo "Résultats générés :"
echo "  - ./cooccurrents-$LANGUE-mot1.txt"
if [[ -n "$MOT2" ]]; then
    echo "  - ./cooccurrents-$LANGUE-mot2.txt"
fi