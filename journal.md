# La vie des mots sur le Web: "conscience"

## (Géraldine) 2/12 - Recherche de liens pour les termes

Je suis en train de constituer ma collection de liens pour les 2 termes qui traduisent en bélarussien les 2 sens principaux du mot "conscience":

- **свядомасць**: domaines psychologique, voire philosophique (faculté d'un individu de se connaître dans sa propre réalité et de juger celle-ci en conséquence)
- **сумленне**: la conscience morale -> dimension éthique

J'avoue que j'ai encore du mal à déterminer ce qui constitue une "bonne" page (ie vraiment pertinente pour le projet)...


## (Maïwenn) 18/12 - Modifications du script et créations des dossiers

J'ai fini de modifier le script afin de récupérer les aspirations et dumps textuels des pages, et je les ai ajoutés en colonne du tableau. J'ai aussi ajouté les dossiers nécessaires pour cela donc les dossiers aspirations, dumps-text, et URLs.


## (Géraldine) 29/12 - Changement de langue

J'ai finalement décidé d'opter pour le russe plutôt que le biélorusse, car il était décidément trop compliqué de trouver des pages réellement pertinentes dans cette langue.
Les termes-cibles en russe seront donc **сознание** et **совесть**, qui sont des équivalents exacts de (respectivement) *свядомасць* et *сумленне* du biélorusse.

Problèmes avec:
* une des pages Web, qui contient un PDF (pas d'encodage reconnu -> pas de cyrillique);
* ainsi qu'avec une autre, qui utilise JavaScript (ce qui a l'air de poser des problèmes à lynx et curl...).

## (Maïwenn) 03/01 - Contextes

J'ai ajouté un script à part pour récupérer les contextes pour chaque occurence (2 lignes avant et après) et cela pour les 2 acceptions de mon mot. J'ai modifié le script principal pour qu'il appelle ce script et ainsi pouvoir récupérer les contextes pour chaque fichier et en ajouter le lien vers le fichier txt correspondant dans le tableau. J'ai donc ajouté aussi le dossier contextes.


## (Géraldine) 06/01 - Modification de script

1.⁠ ⁠J'ai essayé d'améliorer le script d'origine et y ai ajouté tout un tas de conditions, afin qu'il soit plus rigoureux et s'adapte à nos 3 langues. Les conditions permettent d'avoir une marche à suivre adaptée en fonction du code HTTP, de l'encodage trouvé (ou pas), du résultat de la conversion en UTF-8 quand celle-ci est nécessaire...
2. J'ai dû recourir à Pandoc, car Lynx posait des problèmes avec l'alphabet cyrillique: il retranscrivait automatiquement le cyrillique en translittération latine, peut-être à cause d'une mauvaise détection de l'encodage des fichiers de sa part? J'ai essayé de forcer Lynx à interpréter le fichier aspiré comme de l'UTF-8 et à générer la sortie du dump en UTF-8, mais en vain.
3.⁠ ⁠Comme je travaille sur le russe, qui est une langue à déclinaisons, j'ai choisi, pour l'ex. 4 sur les occurrences, de lire les occurrences des mots à partir du fichier variantes.txt, afin que toutes les déclinaisons soient prises en compte. Finalement, après discussion avec mes camarades, nous avons opté pour une méthode hybride: l'utilisateur peut soit rentrer un mot à chercher puis l'autre, soit passer en argument 2 fichiers textes variantes (1 pour chaque mot, avec toutes les déclinaisons du mot dans mon cas). Le script ajoute au tableau une colonne pour chaque mot, avec le nombre de ses occurrences, variantes incluses.
4.⁠ ⁠J'ai aussi ajouté, au début du script, le nettoyage de certains répertoires automatiquement, pour ne plus avoir à le faire à la main avant chaque test du code.
