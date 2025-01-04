i=O
for file in ./dumps-text/*.txt
do
i=$((i + 1))
grep -i -A 2 -B 2 "conscience" $file > ./contextes/anglais-mot1-$i.txt
grep -i -A 2 -B 2 "consciousness" $file > ./contextes/anglais-mot2-$i.txt
done
