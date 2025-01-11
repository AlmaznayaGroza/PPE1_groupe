#!/bin/bash

FICHIER=$1
OUTPUT=$2
FICHIER1=$3
FICHIER2=$4

# Traitement des arguments 4 et 5 (fichiers de variantes ou mots à saisir)
if [[ -f "$FICHIER1" && -f "$FICHIER2" ]]; then
    VARIANTES_FILE1="$FICHIER1"
    VARIANTES_FILE2="$FICHIER2"
    MOT1=""
    MOT2=""
    echo "Fichiers détectés : $FICHIER1 et $FICHIER2"
else
    while [[ -z "$MOT1" ]]; do
        echo "Veuillez entrer le premier mot pour la recherche :"
        read MOT1
        MOT1=$(echo "$MOT1" | tr '[:upper:]' '[:lower:]' | xargs)  # Nettoyage des espaces inutiles
        if [[ -z "$MOT1" ]]; then
            echo "Erreur : veuillez entrer un mot 1."
        fi
    done
    echo "Premier mot après conversion : $MOT1"

    while [[ -z "$MOT2" ]]; do
        echo "Veuillez entrer le deuxième mot pour la recherche :"
        read MOT2
        MOT2=$(echo "$MOT2" | tr '[:upper:]' '[:lower:]' | xargs)  # Nettoyage des espaces inutiles
        if [[ -z "$MOT2" ]]; then
            echo "Erreur : le mot ne peut pas être vide. Veuillez réessayer."
        fi
    done
    echo "Deuxième mot après conversion : $MOT2"

    VARIANTES_FILE1=""
    VARIANTES_FILE2=""
fi

# Confirmation des valeurs des arguments
echo "MOT1 : $MOT1"
echo "MOT2 : $MOT2"
echo "VARIANTES_FILE1 : $VARIANTES_FILE1"
echo "VARIANTES_FILE2 : $VARIANTES_FILE2"

# Préparation des variantes pour MOT1
if [[ -n "$VARIANTES_FILE1" ]]; then
    VARIANTES1=$(cat "$VARIANTES_FILE1" | tr '\n' '|' | sed 's/|$//')
else
    VARIANTES1="$MOT1"
fi

# Préparation des variantes pour MOT2
if [[ -n "$VARIANTES_FILE2" ]]; then
    VARIANTES2=$(cat "$VARIANTES_FILE2" | tr '\n' '|' | sed 's/|$//')
else
    VARIANTES2="$MOT2"
fi

# Exécution de la commande Python pour MOT1
echo "Exécution pour MOT1/VARIANTES1 : $VARIANTES1"
python3 programmes/cooccurrents.py "$FICHIER" --target "($VARIANTES1)" --match-mode regex > "$OUTPUT-mot1.txt"

# Exécution de la commande Python pour MOT2
echo "Exécution pour MOT2/VARIANTES2 : $VARIANTES2"
python3 programmes/cooccurrents.py "$FICHIER" --target "($VARIANTES2)" --match-mode regex > "$OUTPUT-mot2.txt"

# Résultats
echo "Résultats générés :"
echo "  - $OUTPUT-mot1.txt (pour MOT1/VARIANTES1)"
echo "  - $OUTPUT-mot2.txt (pour MOT2/VARIANTES2)"