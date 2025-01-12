#!/bin/bash

LANGUE=$1
DOSSIER=$2
FICHIER1=$3
FICHIER2=$4
CONTEXT_WORDS=30

# Vérification des arguments
if [ ! -d "$DOSSIER" ]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas."
    exit 1
fi

# if [[ -f "$MOT1" ]]; then
#     VARIANTES1=($(cat "$MOT1"))
# else
#     VARIANTES1="$MOT1"
# fi

# if [[ -f "$MOT2" ]]; then
#     VARIANTES2=($(cat "$MOT2"))
# else
#     VARIANTES2="$MOT2"
# fi


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


# Création du dossier pour les concordanciers
mkdir -p ./concordances

# Parcours des fichiers commençant par $LANGUE- dans le dossier
for FILE in "$DOSSIER/${LANGUE}"-*.txt; do
    if [ ! -f "$FILE" ]; then
        echo "Aucun fichier trouvé correspondant à '$LANGUE-*' dans le dossier '$DOSSIER'."
        continue
    fi

    BASENAME=$(basename "$FILE" .txt)

    # Gérer les variantes du premier groupe (VARIANTES1)
    OUTPUT_FILE1="./concordances/${BASENAME}-group1-concordance.html"
    echo "<!DOCTYPE html>
<html lang=\"fr\">
<head>
    <title>Concordancier : $BASENAME (Groupe 1)</title>
    <meta charset=\"UTF-8\">
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
</head>
<body>
    <section class=\"section\">
        <div class=\"container\">
            <h1 class=\"title\">Concordancier pour : <strong>$BASENAME</strong></h1>
            <h2 class=\"subtitle\">Variantes : <strong>$(IFS=,; echo "${VARIANTES1[*]}")</strong></h2>
            <table class=\"table is-striped is-bordered\">
                <thead>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot clé</th>
                        <th>Contexte droit</th>
                    </tr>
                </thead>
                <tbody>" > "$OUTPUT_FILE1"

    # Fusionner tout le fichier en une seule ligne
    SINGLE_LINE=$(tr '\n' ' ' < "$FILE" | sed 's/[[:space:]]\+/ /g')

    echo "$SINGLE_LINE" | sed -E "s/ /\n/g" | awk -v context="$CONTEXT_WORDS" '
    BEGIN {
        split("'"${VARIANTES1[*]}"'", variantes, " ")
        for (v in variantes) {
            lower_variantes[tolower(variantes[v])] = 1
        }
    }
    {
        words[NR] = $0
    }
    END {
        for (i = 1; i <= NR; i++) {
            if (tolower(words[i]) in lower_variantes) {
                left = ""
                for (j = (i - context); j < i; j++) {
                    if (j > 0) left = left " " words[j]
                }
                right = ""
                for (j = (i + 1); j <= (i + context); j++) {
                    if (j <= NR) right = right " " words[j]
                }
                printf "<tr><td>%s</td><td><strong>%s</strong></td><td>%s</td></tr>\n", left, words[i], right
            }
        }
    }' >> "$OUTPUT_FILE1"

    echo "                </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$OUTPUT_FILE1"

    # Gérer les variantes du deuxième groupe (VARIANTES2)
    OUTPUT_FILE2="./concordances/${BASENAME}-group2-concordance.html"
    echo "<!DOCTYPE html>
<html lang=\"fr\">
<head>
    <title>Concordancier : $BASENAME (Groupe 2)</title>
    <meta charset=\"UTF-8\">
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
</head>
<body>
    <section class=\"section\">
        <div class=\"container\">
            <h1 class=\"title\">Concordancier pour : <strong>$BASENAME</strong></h1>
            <h2 class=\"subtitle\">Variantes : <strong>$(IFS=,; echo "${VARIANTES2[*]}")</strong></h2>
            <table class=\"table is-striped is-bordered\">
                <thead>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot clé</th>
                        <th>Contexte droit</th>
                    </tr>
                </thead>
                <tbody>" > "$OUTPUT_FILE2"

    echo "$SINGLE_LINE" | sed -E "s/ /\n/g" | awk -v context="$CONTEXT_WORDS" '
    BEGIN {
        split("'"${VARIANTES2[*]}"'", variantes, " ")
        for (v in variantes) {
            lower_variantes[tolower(variantes[v])] = 1
        }
    }
    {
        words[NR] = $0
    }
    END {
        for (i = 1; i <= NR; i++) {
            if (tolower(words[i]) in lower_variantes) {
                left = ""
                for (j = (i - context); j < i; j++) {
                    if (j > 0) left = left " " words[j]
                }
                right = ""
                for (j = (i + 1); j <= (i + context); j++) {
                    if (j <= NR) right = right " " words[j]
                }
                printf "<tr><td>%s</td><td><strong>%s</strong></td><td>%s</td></tr>\n", left, words[i], right
            }
        }
    }' >> "$OUTPUT_FILE2"

    echo "                </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$OUTPUT_FILE2"

done

echo "Tous les concordanciers ont été générés dans le dossier ./concordances"