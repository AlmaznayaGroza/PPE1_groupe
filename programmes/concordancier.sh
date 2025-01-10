#!/bin/bash

LANGUE=$1
MOT1=$2
MOT2=$3
FILE=$4
CONTEXT_WORDS=30


# Si les arguments sont des fichiers, concaténer leur contenu et l'assigner à la variable variantes, sinon assigner le mot entré en argument à la variable variantes
if [[ -f "$MOT1" ]]; then
    VARIANTES1=($(cat "$MOT1"))
else
    VARIANTES1="$MOT1"
fi

if [[ -f "$MOT2" ]]; then
    VARIANTES2=($(cat "$MOT2"))
else
    VARIANTES2="$MOT2"
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

    #echo "Concordancier généré pour $BASENAME avec Groupe 1 dans $OUTPUT_FILE1"

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

    #echo "Concordancier généré pour $BASENAME avec Groupe 2 dans $OUTPUT_FILE2"


#echo "Tous les concordanciers ont été générés dans le dossier ./concordances"
