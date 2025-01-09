#!/bin/bash

LANGUE=$1
FICHIER1=$2
FICHIER2=$3
CONTEXT_WORDS=30

# Charger les variantes ou demander à l'utilisateur d'entrer des mots
if [[ -f "$FICHIER1" ]]; then
    VARIANTES1=($(cat "$FICHIER1"))
else
    echo "Aucun fichier pour les variantes du premier groupe trouvé. Entrez le mot 1 :"
    read -r USER_INPUT1
    VARIANTES1=($USER_INPUT1)
fi

if [[ -f "$FICHIER2" ]]; then
    VARIANTES2=($(cat "$FICHIER2"))
else
    echo "Aucun fichier pour les variantes du deuxième groupe trouvé. Entrez le mot 2 :"
    read -r USER_INPUT2
    VARIANTES2=($USER_INPUT2)
fi

# Supprimer tous les fichiers dans le dossier ./concordances/
if [[ -d "./concordances" ]]; then
    rm -rf ./concordances/*
    echo "Tous les fichiers dans ./concordances/ ont été supprimés."
fi

# Boucle sur chaque fichier d'entrée
for FILE in ./dumps-text/$LANGUE-*.txt;
do
    if [[ ! -f "$FILE" ]]; then
        echo "Aucun fichier texte trouvé : $FILE."
        continue
    fi

    BASENAME=$(basename "$FILE" .txt)

    # Gérer les variantes du premier groupe (VARIANTES1)
    OUTPUT_FILE1="./concordances/${BASENAME}_group1_concordance.html"
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

    echo "Concordancier généré pour $BASENAME avec Groupe 1 dans $OUTPUT_FILE1"

    # Gérer les variantes du deuxième groupe (VARIANTES2)
    OUTPUT_FILE2="./concordances/${BASENAME}_group2_concordance.html"
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

    echo "Concordancier généré pour $BASENAME avec Groupe 2 dans $OUTPUT_FILE2"
done

echo "Tous les concordanciers ont été générés dans le dossier ./concordances"
