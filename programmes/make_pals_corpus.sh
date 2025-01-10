DOSSIER=$1
LANGUE=$2

rm -rf ./dumps-text/$LANGUE-cleaned-*.txt
rm -rf ./contextes/$LANGUE-*-cleaned-*.txt


i=1
for file in ./dumps-text/$LANGUE-*.txt
do
bash ./programmes/clean.sh "$file" "./dumps-text/$LANGUE-cleaned-$i.txt"
egrep -o  "\b\w*\b|[[:punct:]]" "./dumps-text/$LANGUE-cleaned-$i.txt"
i=$((i + 1))

done > ./$DOSSIER/dump-$LANGUE.txt


j=1
for file in ./contextes/$LANGUE-mot1-*.txt
do
bash ./programmes/clean.sh "./contextes/$LANGUE-mot1-$j.txt" "./contextes/$LANGUE-mot1-cleaned-$j.txt"
egrep -o  "\b\w*\b|[[:punct:]]" "./contextes/$LANGUE-mot1-cleaned-$j.txt"
j=$((j + 1))
done > ./$DOSSIER/contexte-$LANGUE.txt

k=1
for file in ./contextes/$LANGUE-mot2-*.txt
do
bash ./programmes/clean.sh "./contextes/$LANGUE-mot2-$j.txt" "./contextes/$LANGUE-mot2-cleaned-$j.txt"
egrep -o  "\b\w*\b|[[:punct:]]" "./contextes/$LANGUE-mot2-cleaned-$j.txt"
k=$((k + 1))
done >> ./$DOSSIER/contexte-$LANGUE.txt
