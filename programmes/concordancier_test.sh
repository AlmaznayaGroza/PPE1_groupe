#!/bin/bash

LANGUE=$1
KEYWORD=$2
CONTEXT_WORDS=30

i=0
for file in ./dumps-text/$LANGUE-*.txt
do
# Fusionner tout le fichier en une seule ligne
SINGLE_LINE=$(tr '\n' ' ' < "$file" | sed 's/[[:space:]]\+/ /g')

i=$((i + 1))
# Préparer le fichier de sortie
echo "<!DOCTYPE html>
<html lang=\"fr\">
<head>
    <title>Concordancier</title>
    <meta charset=\"UTF-8\">
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
</head>
<body>
    <section class=\"section\">
        <div class=\"container\">
            <h1 class=\"title\">Concordancier</h1>
            <table class=\"table is-striped is-bordered\">
                <thead>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot clé</th>
                        <th>Contexte droit</th>
                    </tr>
                </thead>
                <tbody>" > ./concordances/$LANGUE-$i.html

# echo pour lire le contenu de la variable SINGLE_LINE, sed pour remplacer les espaces par des sauts de ligne pour avoir 1 mot par ligne, awk est utilisé pour rechercher le mot clé (défini par keyword) et extraire un certain nombre de mots avant et après (défini par context). 
echo "$SINGLE_LINE" | sed -E "s/ /\n/g" | awk -v keyword="$KEYWORD" -v context="$CONTEXT_WORDS" '
{
    words[NR] = $0
}
END {
    for (i = 1; i <= NR; i++) {
        if (tolower(words[i]) == tolower(keyword)) {
            # Construire le contexte gauche
            left = ""
            for (j = (i - context); j < i; j++) {
                if (j > 0) left = left " " words[j]
            }
            # Construire le contexte droit
            right = ""
            for (j = (i + 1); j <= (i + context); j++) {
                if (j <= NR) right = right " " words[j]
            }
            # Afficher le résultat dans le tableau HTML
            printf "<tr><td>%s</td><td><strong>%s</strong></td><td>%s</td></tr>\n", left, words[i], right
        }
    }
}' >> ./concordances/$LANGUE-$i.html

echo "                </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> ./concordances/$LANGUE-$i.html

done
echo "Concordanciers générés"


# {
#     # Chaque mot est lu et stocké dans un tableau nommé 'words', où l'index est basé sur le numéro de ligne (NR).
#     # Cela permet de manipuler chaque mot individuellement plus tard.
#     words[NR] = $0
# }
# END {
#     # Le bloc `END` s'exécute une fois que toutes les lignes d'entrée ont été lues.
#     # Il est utilisé ici pour analyser les mots stockés dans le tableau `words`.

#     for (i = 1; i <= NR; i++) {
#         # Parcourt tous les mots du tableau `words`.
#         # `i` représente la position actuelle dans le tableau.
#         # `NR` est le nombre total de mots (lignes) lus dans le fichier.

#         if (tolower(words[i]) == tolower(keyword)) {
#             # Vérifie si le mot à la position actuelle (words[i]) correspond au mot-clé (`keyword`).
#             # `tolower` est utilisé pour rendre la comparaison insensible à la casse.

#             # Construire le contexte gauche
#             left = ""  # Initialise une chaîne vide pour stocker les mots du contexte gauche.
#             for (j = (i - context); j < i; j++) {
#                 # Parcourt les mots précédant le mot-clé, jusqu'à un maximum de `context` mots.
#                 # `(i - context)` est la position de départ pour le contexte gauche.
#                 # `j < i` s'assure qu'on ne dépasse pas le mot-clé.

#                 if (j > 0) left = left " " words[j]
#                 # Vérifie que `j` est un index valide (supérieur à 0).
#                 # Si valide, ajoute le mot correspondant (`words[j]`) à la chaîne `left`.
#                 # Les mots sont séparés par un espace.
#             }

#             # Construire le contexte droit
#             right = ""  # Initialise une chaîne vide pour stocker les mots du contexte droit.
#             for (j = (i + 1); j <= (i + context); j++) {
#                 # Parcourt les mots suivant le mot-clé, jusqu'à un maximum de `context` mots.
#                 # `(i + 1)` est la position de départ pour le contexte droit.
#                 # `(i + context)` est la position maximale pour le contexte droit.

#                 if (j <= NR) right = right " " words[j]
#                 # Vérifie que `j` est un index valide (inférieur ou égal au nombre total de mots, NR).
#                 # Si valide, ajoute le mot correspondant (`words[j]`) à la chaîne `right`.
#             }

#             # Afficher le résultat dans le tableau HTML
#             printf "<tr><td>%s</td><td><strong>%s</strong></td><td>%s</td></tr>\n", left, words[i], right
#             # Génère une ligne HTML avec :
#             # - `<td>%s</td>` : La cellule contenant le contexte gauche (`left`).
#             # - `<td><strong>%s</strong></td>` : La cellule contenant le mot-clé en gras (`words[i]`).
#             # - `<td>%s</td>` : La cellule contenant le contexte droit (`right`).
#         }
#     }
# }
