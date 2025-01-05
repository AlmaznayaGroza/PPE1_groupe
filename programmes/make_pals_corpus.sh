DOSSIER=$1
LANGUE=$2

for file in ./dumps-text/$LANGUE-*.txt
do
egrep -o  "\b\w*\b|[[:punct:]]" $file
done > ./$DOSSIER/dump-$LANGUE.txt

