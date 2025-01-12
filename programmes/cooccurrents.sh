#!/bin/bash

# Vérification des arguments obligatoires
if [ $# -lt 4 ]; then
    echo "Usage: $0 DOSSIER_SOURCE CODE_LANGUE OUTPUT VARIANTES1 VARIANTES2 [STOPWORDS]"
    echo "  DOSSIER_SOURCE : dossier contenant les fichiers texte à analyser"
    echo "  CODE_LANGUE : code de la langue (ex: ru)"
    echo "  OUTPUT : préfixe pour les fichiers de sortie"
    echo "  VARIANTES1 : fichier des variantes du premier mot"
    echo "  VARIANTES2 : fichier des variantes du deuxième mot"
    echo "  STOPWORDS : fichier de stopwords (optionnel)"
    exit 1
fi

# Récupération des arguments
DOSSIER_SOURCE=$1
CODE_LANGUE=$2
OUTPUT=$3
VARIANTES_FILE1=$4
VARIANTES_FILE2=$5
STOPWORDS=$6

# Vérification du dossier source
if [ ! -d "$DOSSIER_SOURCE" ]; then
    echo "Erreur : le dossier source '$DOSSIER_SOURCE' n'existe pas"
    exit 1
fi

# Vérification du dossier de sortie
OUTPUT_DIR=$(dirname "$OUTPUT")
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Création du dossier de sortie : $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR" || {
        echo "Erreur : impossible de créer le dossier de sortie '$OUTPUT_DIR'"
        exit 1
    }
fi

# Vérification des fichiers de variantes
for fichier in "$VARIANTES_FILE1" "$VARIANTES_FILE2"; do
    if [ ! -r "$fichier" ]; then
        echo "Erreur : le fichier de variantes '$fichier' n'existe pas ou n'est pas lisible"
        exit 1
    fi
done

# Vérification du fichier stopwords
if [[ -n "$STOPWORDS" ]]; then
    if [ ! -f "$STOPWORDS" ]; then
        echo "Erreur : le fichier stopwords '$STOPWORDS' n'existe pas"
        exit 1
    fi
    echo "Utilisation du fichier stopwords : $STOPWORDS"
else
    echo "Aucun fichier stopwords spécifié"
fi

# Préparation des variantes
VARIANTES1=$(cat "$VARIANTES_FILE1" | tr '\n' '|' | sed 's/|$//')
VARIANTES2=$(cat "$VARIANTES_FILE2" | tr '\n' '|' | sed 's/|$//')

# Création d'un fichier temporaire pour concaténer tous les fichiers de la langue
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

# Concaténation de tous les fichiers de la langue spécifiée
echo "Concaténation des fichiers ${CODE_LANGUE}-*.txt..."
cat "$DOSSIER_SOURCE/${CODE_LANGUE}"-*.txt > "$TMP_FILE"

# Exécution des commandes Python
echo "Traitement des cooccurrences pour le premier ensemble de variantes..."
if ! python3 programmes/cooccurrents.py "$TMP_FILE" --target "($VARIANTES1)" --match-mode regex ${STOPWORDS:+--stopwords "$STOPWORDS"} > "$OUTPUT-mot1.txt"; then
    echo "Erreur lors de l'exécution du script Python pour le premier mot"
    exit 1
fi

echo "Traitement des cooccurrences pour le second ensemble de variantes..."
if ! python3 programmes/cooccurrents.py "$TMP_FILE" --target "($VARIANTES2)" --match-mode regex ${STOPWORDS:+--stopwords "$STOPWORDS"} > "$OUTPUT-mot2.txt"; then
    echo "Erreur lors de l'exécution du script Python pour le second mot"
    exit 1
fi

echo "Résultats générés avec succès :"
echo "  - $OUTPUT-mot1.txt"
echo "  - $OUTPUT-mot2.txt"