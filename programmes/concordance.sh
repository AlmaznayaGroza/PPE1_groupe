i=O
for file in ./dumps-text/*.txt
do
i=$((i + 1))
echo "<!DOCTYPE html>
	<html lang=\"fr\">
		<head>
			<title>Concordances</title>
			<meta charset=\"UTF-8\">
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
                <tbody> " > ./concordances/anglais-mot1-$i.html

echo "<!DOCTYPE html>
	<html lang=\"fr\">
		<head>
			<title>Concordances</title>
			<meta charset=\"UTF-8\">
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
                <tbody>" > ./concordances/anglais-mot>2-$i.html

grep -i -A 2 -B 2 --group-separator=$'\n' "conscience" $file | sed -E 's/(\n.+)(conscience)(.+\n)/<tr><td>\1</td><td>\2</td><td>\3</td></tr>"/g' > ./concordances/anglais-$i.html
done
