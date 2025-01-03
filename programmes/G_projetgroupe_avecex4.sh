#!/bin/bash

FICHIER=$1
OUTPUT=$2
LANGUE=$3
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VARIANTES_FILE="$SCRIPT_DIR/variantes.txt"


# Vérification des arguments
if [[ ! -f "$FICHIER" ]]; then
    echo "Erreur: fichier d'entrée '$FICHIER' introuvable."
    exit 1
fi

if [[ ! -f "$VARIANTES_FILE" ]]; then
    echo "Erreur : le fichier 'variantes.txt' est introuvable dans $SCRIPT_DIR." >&2
    exit 1
fi

{
echo "<!DOCTYPE html>
<html lang=\"fr\">
<head>
    <title>Tableau des URLs</title>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">
</head>
<body>
    <section class=\"section has-background-primary-light\">
        <div class=\"container\">
            <div class=\"hero has-text-centered\">
                <div class=\"hero-body\">
                    <h1 class=\"title is-2 has-text-primary-dark\">Programmation et Projet Encadré</h1>
                </div>
            </div>
            <nav class=\"tabs is-centered is-toggle is-toggle-rounded\">
                <ul>
                    <li><a href=\"index.html\"><span>Accueil</span></a></li>
                    <li class=\"is-active\"><a href=\"tableau.html\"><span>Tableau</span></a></li>
                </ul>
            </nav>
            <div class=\"table-container mt-4\">
                <table class=\"table is-bordered is-striped is-hoverable is-fullwidth\">
                    <h2 class=\"subtitle is-4 has-text-centered has-text-primary-dark\">Résultats de l'analyse des URLs</h2>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>URL</th>
                            <th>Code HTTP</th>
                            <th>Encodage</th>
                            <th>Nombre de mots</th>
                            <th>Aspiration</th>
                            <th>Dump</th>
                            <th>Compte</th>
                        </tr>
                    </thead>
                    <tbody>"

# Initialisation du numéro de ligne
lineno=1

# Lire le fichier ligne par ligne	
while read -r URL; do
    # Nettoyage de l'URL : supprimer les caractères de retour chariot et les espaces inutiles de l'URL (si présents)
    URL=$(echo "$URL" | tr -d '\r' | xargs)
    echo "Analyse de l'URL $URL" >&2

    # Récupérer le code HTTP et le type de contenu sans aspirer directement
    reponse=$(curl --connect-timeout 5 -s -L -w "%{content_type}\t%{http_code}" -o /dev/null "$URL")
    http_code=$(echo "$reponse" | cut -f2)
    # Extraire l'encodage du type de contenu
    content_type=$(echo "$reponse" | cut -f1)
    encodage=$(echo "$content_type" | egrep -o "charset=\S+" | cut -d "=" -f2 | tail -n1)
    # Valeur par défaut si encodage est vide (car non trouvé)
    encodage=${encodage:-"N/A"}

    # Si le code HTTP est 200
    if [[ $http_code == "200" ]]; then
        # Aspirer le contenu de l'URL
        curl --connect-timeout 5 -s -L -o "./aspirations/$LANGUE-$lineno.html" "$URL" > /dev/null 2>&1
        # Si le fichier aspiré est significatif (taille > 100 octets)
        if [[ -s "./aspirations/$LANGUE-$lineno.html" && $(wc -c < "./aspirations/$LANGUE-$lineno.html") -gt 100 ]]; then
            # Si l'encodage est "N/A"
            if [[ "$encodage" == "N/A" ]]; then
                # Détecter l'encodage avec 'file' et afficher un message
                encodage=$(file --mime-encoding "./aspirations/$LANGUE-$lineno.html" | awk '{print $2}')
                echo "Encodage non spécifié dans l'en-tête pour $URL. Encodage détecté : $encodage" >&2
            fi

            converted_flag=""
            # Si l'encodage trouvé n'est pas UTF-8 et n'est pas "N/A"
            if [[ ! "$encodage" =~ ^[uU][tT][fF]-8$ && "$encodage" != "N/A" ]]; then
                # Si la conversion du fichier aspiré en UTF-8 a fonctionné
                if iconv -f "$encodage" -t UTF-8 "./aspirations/$LANGUE-$lineno.html" > "./aspirations/$LANGUE-$lineno-converted.html" 2>/dev/null; then
                    # Remplacer le fichier aspiré par le fichier converti
                    mv "./aspirations/$LANGUE-$lineno-converted.html" "./aspirations/$LANGUE-$lineno.html"
                    echo "Conversion en UTF-8 réussie pour $URL (encodage détecté : $encodage)" >&2
                    # Marquer le fichier comme converti
                    converted_flag="UTF-8"
                # Sinon, afficher un message d'erreur et supprimer le fichier aspiré + initialiser les valeurs à vide
                else
                    echo "Erreur : échec de la conversion en UTF-8 pour $URL (encodage détecté : $encodage)" >&2
                    rm -f "./aspirations/$LANGUE-$lineno-converted.html"
                    nb_mots=""
                    compte=""
                    aspiration=""
                    dumplink=""
                fi
            fi
            # Si l'encodage est UTF-8 ou si le fichier a été converti avec succès
            if [[ "$encodage" =~ ^[uU][tT][fF]-8$ || -n "$converted_flag" ]]; then
                # Calculer le nombre de mots dans le fichier aspiré avec pandoc
                nb_mots=$(pandoc -f html -t plain ./aspirations/$LANGUE-$lineno.html 2>/dev/null | wc -w)
                # Sauvegarder le dump text avec pandoc
                pandoc -f html -t plain ./aspirations/$LANGUE-$lineno.html -o ./dumps-text/$LANGUE-$lineno.txt >/dev/null 2>&1
                # Compter les occurrences du mot étudié dans le fichier dump
                compte=$(grep -o -i -f "$VARIANTES_FILE" ./dumps-text/$LANGUE-$lineno.txt | wc -l)
            else
                # Si l'encodage n'est pas UTF-8, remplacer les valeurs dans le tableau et supprimer les fichiers
                nb_mots=""
                compte=""
                aspiration=""
                dumplink=""
                rm -f "./aspirations/$LANGUE-$lineno.html" "./dumps-text/$LANGUE-$lineno.txt"
            fi
            # Si le nombre de mots dans le fichier dump est inférieur à 10, supprimer les fichiers et réinitialiser les valeurs à vide
            if [[ $nb_mots -lt 10 ]]; then
                echo "Nombre de mots insuffisant pour l'URL : $URL (moins de 10 mots). Suppression des fichiers." >&2
                nb_mots=""
                encodage=""
                aspiration=""
                dumplink=""
                compte=""
                rm -f "./aspirations/$LANGUE-$lineno.html" "./dumps-text/$LANGUE-$lineno.txt"
            # Sinon, afficher les liens vers le fichier aspiré et le dump text
            else
                aspiration="<a href='../aspirations/$LANGUE-$lineno.html'>aspiration</a>"
                dumplink="<a href='../dumps-text/$LANGUE-$lineno.txt'>dump</a>"
            fi
            # Si le fichier a été converti, ajouter "(UTF-8)" dans la colonne dump
            if [[ -n "$converted_flag" && -f "./dumps-text/$LANGUE-$lineno.txt" ]]; then
                dumplink="$dumplink<br>$converted_flag"
            fi
        # Sinon, si le fichier aspiré est vide ou non significatif (taille <= 100 octets) malgré un code HTTP 200
        else
            # Afficher un message d'erreur et initialiser les valeurs à vide
            echo "Le fichier aspiré pour l'URL $URL est vide ou non significatif malgré un code HTTP 200." >&2
            nb_mots=""
            aspiration=""
            dumplink=""
            compte=""
        fi
    # Sinon, si le code HTTP est différent de 200, afficher un message d'erreur et initialiser les valeurs à vide
    else
        echo "L'URL suivante n'est pas valide ou introuvable : $URL (code HTTP = $http_code)" >&2
        nb_mots=""
        encodage=""
        aspiration=""
        dumplink=""
        compte=""
    fi

    # Préparer les valeurs d'affichage
    encodage_display="${encodage:-/}"
    nb_mots_display="${nb_mots:-/}"
    compte_display="${compte:-/}"
    aspiration_display="${aspiration:-/}"
    dumplink_display="${dumplink:-/}"

    echo "<tr>
        <td>$lineno</td>
        <td><a class=\"has-text-primary\" href=\"$URL\">$URL</a></td>
        <td>$http_code</td>
        <td>$encodage_display</td>
        <td>$nb_mots_display</td>
        <td>$aspiration_display</td>
        <td>$dumplink_display</td>
        <td>$compte_display</td>
    </tr>"

    ((lineno++))
done < "$FICHIER"

echo "				</tbody>
                </table>
            </div>
        </div>
    </section>
</body>
</html>"
} > "$OUTPUT"