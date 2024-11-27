#!/bin/bash

FICHIER=$1
OUTPUT="../tableaux/tableau.html"

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
								</tr>
							</thead>
                    		<tbody>"

lineno=1

while read -r URL; do

	reponse=$(curl -s -L -w "%{content_type}\t%{http_code}" -o /tmp/contenupages.html $URL)
	http_code=$(echo "$reponse" | cut -f2)
	content_type=$(echo "$reponse" | cut -f1)
	encodage=$(echo "$content_type" | egrep -o "charset=\S+" | cut -d "=" -f2 | tail -n1)
	# valeur par défaut si encodage est vide (car non trouvé)
	encodage=${encodage:-"N/A"}
	nb_mots=$(lynx -dump -nolist /tmp/contenupages.html | wc -w | sed 's/^[ \t]*//;s/[ \t]*$//')
	# sed supprime les éventuels tabulations ou espaces qui traînent en début et fin de ligne
	
	#echo -e "$lineno\t$URL\t$http_code\t$encodage\t$nb_mots"
	
	echo "<tr>
		<td>$lineno</td>
		<td><a class=\"has-text-primary\" href=\"$URL\">$URL</a></td>
		<td>$http_code</td>
		<td>$encodage</td>
		<td>$nb_mots</td>
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