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

## (Maïwenn) 05/01 - Travail sur le script pour PALS

J'ai commencé à rédiger le script make_pals_corpus pour modifier les fichiers dump-text afin de les rendre lisible par le script PALS.

## (Géraldine) 06/01 - Modification de script

1.⁠ ⁠J'ai essayé d'améliorer le script d'origine et y ai ajouté tout un tas de conditions, afin qu'il soit plus rigoureux et s'adapte à nos 3 langues. Les conditions permettent d'avoir une marche à suivre adaptée en fonction du code HTTP, de l'encodage trouvé (ou pas), du résultat de la conversion en UTF-8 quand celle-ci est nécessaire...
2. J'ai dû recourir à Pandoc, car Lynx posait des problèmes avec l'alphabet cyrillique: il retranscrivait automatiquement le cyrillique en translittération latine, peut-être à cause d'une mauvaise détection de l'encodage des fichiers de sa part? J'ai essayé de forcer Lynx à interpréter le fichier aspiré comme de l'UTF-8 et à générer la sortie du dump en UTF-8, mais en vain.
3.⁠ ⁠Comme je travaille sur le russe, qui est une langue à déclinaisons, j'ai choisi, pour l'ex. 4 sur les occurrences, de lire les occurrences des mots à partir du fichier variantes.txt, afin que toutes les déclinaisons soient prises en compte. Finalement, après discussion avec mes camarades, nous avons opté pour une méthode hybride: l'utilisateur peut soit rentrer un mot à chercher puis l'autre, soit passer en argument 2 fichiers textes variantes (1 pour chaque mot, avec toutes les déclinaisons du mot dans mon cas). Le script ajoute au tableau une colonne pour chaque mot, avec le nombre de ses occurrences, variantes incluses.
4.⁠ ⁠J'ai aussi ajouté, au début du script, le nettoyage de certains répertoires automatiquement, pour ne plus avoir à le faire à la main avant chaque test du code.

## (Maïwenn) 06/01 - Fusion du script contextes avec le script principal

J'ai ajouté et adapté le contenu du script que j'avais fait pour capter les contextes au script principal afin de tout centraliser dans un seul script. J'ai commencé à réfléchir pour le concordancier, mais j'ai du mal à voir comment récupérer le contexte gauche et droit pour les mettre dans un tableau avec sed.

## (Géraldine) 07/01 - Amélioration script

- si, en l'absence de fichiers en arguments, l'utilisateur ne rentre pas de mots, ou s'il ne rentre pas de noms pour les entêtes de colonnes -> msg d'erreur + proposition de réessayer 
- fusion des Headers 1 & 3, et 2 & 4
- correction pour la vérification de l'existence des fichiers variantes
- ajout du numéro de ligne à chaque itération ("Analyse de l'URL n°$lineno :")
- dans la boucle, séparer compte et contexte + ajout d'un sed dans contexte pour rajouter des "--------" entre chaque citation capturée

## (Marina) 10/01 - Travail effectué

- Reconstitution complet des URLS suite à un problème technique ('Détaillé par mail + Ubuntu via Microsoft Store donc modification de certaines manipulation')
- Hésitation sur le mots espagnol: "conciencia" et "consciencia" signifie la même chose cependant 2 orthographes possibles mais une plus utilisé que l'autre
- Lecture des scripts, pour vérifier si possibilité d'amélioration
- Ajout des dossiers de la troisième langue 
- Petit problème avec l'envoie de certains fichiers
- Modification et ajout de certaines informations sur le script de la pages (site) 

## (Marina) 11/01 

- Upload les nouveaux dossiers via les nouveaux Scripts
- Création complète d'une clé SSH
- Entrain de définir les mots pour la langue Es dans l'Index.html 
