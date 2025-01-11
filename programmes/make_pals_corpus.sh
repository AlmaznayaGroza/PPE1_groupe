DOSSIER=$1
LANGUE=$2

rm -rf ./dumps-text/$LANGUE-cleaned-*.txt
rm -rf ./contextes/$LANGUE-*-cleaned-*.txt

#Concaténer les fichiers nettoyés des dumps
i=1
for file in ./dumps-text/$LANGUE-*.txt
do
bash ./programmes/clean.sh "$file" "./dumps-text/$LANGUE-cleaned-$i.txt"
i=$((i + 1))
done
cat ./dumps-text/$LANGUE-cleaned-*.txt > ./$DOSSIER/dump-$LANGUE.txt

#Concaténer les fichiers nettoyés des contextes (mot 1 et mot 2)
j=1
for file in ./contextes/$LANGUE-mot1-*.txt
do
bash ./programmes/clean.sh "./contextes/$LANGUE-mot1-$j.txt" "./contextes/$LANGUE-mot1-cleaned-$j.txt"
j=$((j + 1))
done

k=1
for file in ./contextes/$LANGUE-mot2-*.txt
do
bash ./programmes/clean.sh "./contextes/$LANGUE-mot2-$k.txt" "./contextes/$LANGUE-mot2-cleaned-$k.txt"
k=$((k + 1))
done

cat ./contextes/$LANGUE-*-cleaned-*.txt > ./$DOSSIER/contexte-$LANGUE.txt
