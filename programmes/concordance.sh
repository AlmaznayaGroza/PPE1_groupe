i=1
for file in ./dumps-text/anglais-*.txt
do
i=$((i + 1))
echo '<!DOCTYPE html>
	<html>
		<head>
			<title>Concordances</title>
			<meta charset="UTF-8">
		</head>
		<body>
            <table>
                <thead>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot étudié</th>
                        <th>Contexte droit</th>
                    </tr>
                </thead>
                <tbody>' > ./concordances/anglais-mot1-$i.html

grep -i -A 2 -B 2 --group-separator=$'\n' "conscience" "$file" | sed -E 's/(\n.*)(conscience)(.*\n)/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/g' >> ./concordances/anglais-mot1-$i.html

echo "</tbody></body></html>" >>  ./concordances/anglais-mot1-$i.html

done
