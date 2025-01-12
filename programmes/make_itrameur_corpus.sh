#!/bin/bash

##############################################################################
# Formater et fusionner les fichiers textuels bruts (contextes/<langue>-<mot>-*.txt)
# en un seul fichier pour un usage avec iTrameur
##############################################################################

set -e  # Arrêt du script en cas d’erreur

# --- Vérification des arguments ---
if [ $# -lt 2 ]; then
  echo "Usage : $0 <langue> <mot>"
  echo "Exemple : $0 fr chat"
  exit 1
fi

# --- Récupération des arguments ---
langue="$1"
mot="$2"

# --- Définition des chemins ---
input_dir="contextes"
stopwords_file="programmes/stopwords-${langue}.txt"  # <- ta liste de stopwords
output_dir="itrameur"
output_file="${output_dir}/contextes-${mot}-${langue}.txt"

# --- Création du dossier de sortie s'il n'existe pas ---
mkdir -p "$output_dir"

# --- On vide ou crée le fichier de sortie ---
> "$output_file"

echo "Création du fichier iTrameur : $output_file"

# --- Compteur pour l'attribut id dans <doc> ---
counter=1

set +e  # Désactive l'arrêt sur erreur
for file in "${input_dir}/${langue}-${mot}-cleaned-"*.txt; do
  echo "Traitement du fichier : $file"
  if [ -f "$file" ]; then
    # Pipeline avec gestion des erreurs
    cat "$file" \
      | tr '[:upper:]' '[:lower:]' \
      | if [ -f "$stopwords_file" ]; then
          grep -vwF -f "$stopwords_file" || echo "Erreur grep sur $file" >> log_debug.txt
        else
          cat
        fi \
      >> "$output_file" || echo "Erreur cat sur $file" >> log_debug.txt
  fi
done
set -e  # Réactive l'arrêt sur erreur

echo "Terminé !"
echo "Le fichier final est disponible ici : $output_file"