#!/bin/bash

FICHIER=$1
OUTPUT=$2
LANGUE=$3

# vérif argument
if [[ ! -f "$FICHIER" ]]; then
    echo "Erreur: fichier d'entrée '$FICHIER' introuvable."
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
								</tr>
							</thead>
                    		<tbody>"

lineno=1

while read -r URL; do

	reponse=$(curl --connect-timeout 5 -s -L -w  "%{content_type}\t%{http_code}" -o ./aspirations/$LANGUE-$lineno.html $URL)
	http_code=$(echo "$reponse" | cut -f2)
	content_type=$(echo "$reponse" | cut -f1)
	encodage=$(echo "$content_type" | egrep -o "charset=\S+" | cut -d "=" -f2 | tail -n1)
	# valeur par défaut si encodage est vide (car non trouvé)
	encodage=${encodage:-"N/A"}
	nb_mots=$(lynx -dump -nolist ./aspirations/$LANGUE-$lineno.html | wc -w)
	dump=$(lynx -dump -nolist  ./aspirations/$LANGUE-$lineno.html > ./dumps-text/$LANGUE-$lineno.txt)
	# sed supprime les éventuels tabulations ou espaces qui traînent en début et fin de ligne
	
	#echo -e "$lineno\t$URL\t$http_code\t$encodage\t$nb_mots"
	
	if [ $http_code != "200" ] ;
	then
	echo "$URL n'est pas une URL valide ou elle est introuvable : code http = $http_code" >&2
	nb_mots="/"
	encodage="/"
	content_type="/"
	fi

	dumplink=$(echo "<a href='../dumps-text/$LANGUE-$lineno.txt'>dump</a>")
	aspiration=$(echo "<a href='../aspirations/$LANGUE-$lineno.html'>aspiration</a>")

	echo "<tr>
		<td>$lineno</td>
		<td><a class=\"has-text-primary\" href=\"$URL\">$URL</a></td>
		<td>$http_code</td>
		<td>$encodage</td>
		<td>$nb_mots</td>
		<td>$aspiration</td>
		<td>$dumplink</td>
	</tr>"
	
    ((lineno++))

done < "$FICHIER"

echo "						</tbody>
					</table>
				</div>
			</div>
		</section>
	</body>
</html>"
} > "$OUTPUT"
