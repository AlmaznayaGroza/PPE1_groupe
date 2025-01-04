for file in ./dumps-text/*.txt
do
occurences_conscience=$(grep -i -o "conscience" $file | wc -l )
occurences_consciousness=$(grep -i -o "consciousness" $file | wc -l)
echo -e "$occurences_conscience\t$occurences_consciousness"
done
