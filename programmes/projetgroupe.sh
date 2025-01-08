# TODO
## lien 8 sov (aspiré)
## codes d'erreurs
## dumps avec 0 occurrence du mot

#!/bin/bash

FICHIER=$1
OUTPUT=$2
LANGUE=$3
FICHIER1=$4
FICHIER2=$5
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Traitement des arguments 4 et 5 (fichiers de variantes)
# Si pas d'arguments 4 et 5, demander à l'utilisateur de saisir les mots
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

# Demander à l'utilisateur d'entrer les intitulés des colonnes
while [[ -z "$HEADER1" ]]; do
    echo "Veuillez entrer l'intitulé des colonnes pour mot1/fichier1 :"
    read HEADER1
    if [[ -z "$HEADER1" ]]; then
        echo "Erreur : l'intitulé ne peut pas être vide. Veuillez réessayer."
    fi
done

while [[ -z "$HEADER2" ]]; do
    echo "Veuillez entrer l'intitulé des colonnes pour mot2/fichier2 :"
    read HEADER2
    if [[ -z "$HEADER2" ]]; then
        echo "Erreur : l'intitulé ne peut pas être vide. Veuillez réessayer."
    fi
done

# Supprimer tous les fichiers dans le dossier ./aspirations/
if [[ -d "./aspirations" ]]; then
    rm -rf ./aspirations/*
    echo "Tous les fichiers dans ./aspirations/ ont été supprimés."
fi

# Supprimer tous les fichiers dans le dossier ./dumps-text/
if [[ -d "./dumps-text" ]]; then
    rm -rf ./dumps-text/*
    echo "Tous les fichiers dans ./dumps-text/ ont été supprimés."
fi

# Supprimer tous les fichiers dans le dossier ./tableaux/
if [[ -d "./tableaux" ]]; then
    rm -rf ./tableaux/*
    echo "Tous les fichiers dans ./tableaux/ ont été supprimés."
fi

# Supprimer tous les fichiers dans le dossier ./contextes/
if [[ -d "./contextes" ]]; then
    rm -rf ./contextes/*
    echo "Tous les fichiers dans ./contextes/ ont été supprimés."
fi

# Vérification des arguments
if [[ ! -f "$FICHIER" ]]; then
    echo "Erreur : fichier d'entrée '$FICHIER' introuvable."
    exit 1
fi

if [[ -n "$VARIANTES_FILE1" && ! -f "$VARIANTES_FILE1" ]]; then
    echo "Erreur : le fichier de variantes spécifié '$VARIANTES_FILE1' est introuvable." >&2
    exit 1
fi

if [[ -n "$VARIANTES_FILE2" && ! -f "$VARIANTES_FILE2" ]]; then
    echo "Erreur : le fichier de variantes spécifié '$VARIANTES_FILE2' est introuvable." >&2
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
                            <th>Occurrences du mot ${HEADER1}</th>
                            <th>Occurrences du mot ${HEADER2}</th>
                            <th>Contextes du mot ${HEADER1}</th>
                            <th>Contextes du mot ${HEADER2}</th>
                        </tr>
                    </thead>
                    <tbody>"

# Initialisation du numéro de ligne
lineno=1

# Lire le fichier ligne par ligne	
while read -r URL; do
    # Nettoyage de l'URL : supprimer les caractères de retour chariot et les espaces inutiles de l'URL (si présents)
    URL=$(echo "$URL" | tr -d '\r' | xargs)
    echo "Analyse de l'URL n°$lineno : $URL" >&2

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
                    converted_flag="➔ UTF-8"
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
                # Compter les occurrences et récupère le contexte du mot étudié dans le fichier dump
                if [[ -s "./dumps-text/$LANGUE-$lineno.txt" ]]; then
                    # Comptage des occurrences
                    if [[ -n "$VARIANTES_FILE1" ]]; then
                        compte1=$(grep -o -i -f "$VARIANTES_FILE1" ./dumps-text/$LANGUE-$lineno.txt | wc -l)
                    else
                        compte1=$(grep -o -i "$MOT1" ./dumps-text/$LANGUE-$lineno.txt | wc -l)
                    fi

                    if [[ -n "$VARIANTES_FILE2" ]]; then
                        compte2=$(grep -o -i -f "$VARIANTES_FILE2" ./dumps-text/$LANGUE-$lineno.txt | wc -l)
                    else
                        compte2=$(grep -o -i "$MOT2" ./dumps-text/$LANGUE-$lineno.txt | wc -l)
                    fi

                    # Extraction des contextes
                    if [[ -n "$VARIANTES_FILE1" ]]; then
                        grep -i -A 2 -B 2 -f "$VARIANTES_FILE1" ./dumps-text/$LANGUE-$lineno.txt | sed 's/^--$/---------------/' > ./contextes/$LANGUE-mot1-$lineno.txt
                    else
                        grep -i -A 2 -B 2 "$MOT1" ./dumps-text/$LANGUE-$lineno.txt | sed 's/^--$/---------------/' > ./contextes/$LANGUE-mot1-$lineno.txt
                    fi

                    if [[ -n "$VARIANTES_FILE2" ]]; then
                        grep -i -A 2 -B 2 -f "$VARIANTES_FILE2" ./dumps-text/$LANGUE-$lineno.txt | sed 's/^--$/---------------/' > ./contextes/$LANGUE-mot2-$lineno.txt
                    else
                        grep -i -A 2 -B 2 "$MOT2" ./dumps-text/$LANGUE-$lineno.txt | sed 's/^--$/---------------/' > ./contextes/$LANGUE-mot2-$lineno.txt
                    fi

                    # Liens vers les fichiers de contexte
                    contexte1_link="<a href='../contextes/$LANGUE-mot1-$lineno.txt'>contextes</a>"
                    contexte2_link="<a href='../contextes/$LANGUE-mot2-$lineno.txt'>contextes</a>"

                else
                    compte1=""
                    compte2=""
                    contexte1_link=""
                    contexte2_link=""
                    echo "Le fichier dump pour $URL est vide. Aucun comptage ni contexte extrait."
                fi

            else
                # Si l'encodage n'est pas UTF-8, remplacer les valeurs dans le tableau et supprimer les fichiers
                nb_mots=""
                compte=""
                aspiration=""
                dumplink=""
                compte1=""
                compte2=""
                contexte1_link=""
                contexte2_link=""
                rm -f "./aspirations/$LANGUE-$lineno.html" "./dumps-text/$LANGUE-$lineno.txt"
            fi

            # Si le nombre de mots dans le fichier dump est inférieur à 10, supprimer les fichiers et réinitialiser les valeurs à vide
            if [[ $nb_mots -lt 10 ]]; then
                echo "Nombre de mots insuffisant pour l'URL : $URL (moins de 10 mots). Suppression des fichiers." >&2
                nb_mots=""
                encodage=""
                aspiration=""
                dumplink=""
                compte1=""
                compte2=""
                contexte1_link=""
                contexte2_link=""
                rm -f "./aspirations/$LANGUE-$lineno.html" "./dumps-text/$LANGUE-$lineno.txt"
            # Sinon, afficher les liens vers le fichier aspiré et le dump text
            else
                aspiration="<a href='../aspirations/$LANGUE-$lineno.html'>aspiration</a>"
                dumplink="<a href='../dumps-text/$LANGUE-$lineno.txt'>dump</a>"
                contexte1_link="<a href='../contextes/$LANGUE-mot1-$lineno.txt'>contextes</a>"
                contexte2_link="<a href='../contextes/$LANGUE-mot2-$lineno.txt'>contextes</a>"
            fi
            # Si le fichier a été converti, ajouter "(UTF-8)" dans la colonne dump
            if [[ -n "$converted_flag" && -f "./dumps-text/$LANGUE-$lineno.txt" ]]; then
                encodage="$encodage<br>$converted_flag"
            fi
        # Sinon, si le fichier aspiré est vide ou non significatif (taille <= 100 octets) malgré un code HTTP 200
        else
            # Afficher un message d'erreur et initialiser les valeurs à vide
            echo "Le fichier aspiré pour l'URL $URL est vide ou non significatif malgré un code HTTP 200." >&2
            nb_mots=""
            aspiration=""
            dumplink=""
            compte1=""
            compte2=""
            contexte1_link=""
            contexte2_link=""
        fi
    # Sinon, si le code HTTP est différent de 200, afficher un message d'erreur et initialiser les valeurs à vide
    else
        echo "L'URL suivante n'est pas valide ou introuvable : $URL (code HTTP = $http_code)" >&2
        nb_mots=""
        encodage=""
        aspiration=""
        dumplink=""
        compte1=""
        compte2=""
        contexte1_link=""
        contexte2_link=""
    fi

    # Préparer les valeurs d'affichage
    encodage_display="${encodage:-/}"
    nb_mots_display="${nb_mots:-/}"
    aspiration_display="${aspiration:-/}"
    dumplink_display="${dumplink:-/}"
    header1_display="${compte1:-/}"
    header2_display="${compte2:-/}"
    header3_display="${contexte1_link:-/}"
    header4_display="${contexte2_link:-/}"

    echo "<tr>
        <td>$lineno</td>
        <td><a class=\"has-text-primary\" href=\"$URL\">$URL</a></td>
        <td>$http_code</td>
        <td>$encodage_display</td>
        <td>$nb_mots_display</td>
        <td>$aspiration_display</td>
        <td>$dumplink_display</td>
        <td>$header1_display</td>
        <td>$header2_display</td>
        <td>$header3_display</td>
        <td>$header4_display</td>
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

echo "Toutes les URLs ont été analysées avec succès. Le tableau HTML a été généré dans le fichier '$OUTPUT'."