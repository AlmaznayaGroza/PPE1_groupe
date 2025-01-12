import wordcloud as wc
from wordcloud.wordcloud_cli import parse_args
import sys
import pymorphy2
import inspect
import numpy as np
from PIL import Image

# pour la compatibilité Python 3.12
def getargspec_patch(func):
    spec = inspect.getfullargspec(func)
    return spec.args, spec.varargs, spec.varkw, spec.defaults

inspect.getargspec = getargspec_patch

def load_stopwords(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            stopwords = set(line.strip().lower() for line in file if line.strip())
    except UnicodeDecodeError:
        with open(filepath, 'r', encoding='cp1251') as file:
            stopwords = set(line.strip().lower() for line in file if line.strip())
    return stopwords

def load_mask(mask_path):
    """
    Charge une image et la convertit en un masque approprié pour WordCloud.
    
    Args:
        mask_path: Chemin vers l'image du masque
        
    Returns:
        Un tableau numpy représentant le masque
    """
    # Ouvrir l'image avec PIL
    mask_img = Image.open(mask_path)
    
    # Convertir en niveau de gris si nécessaire
    if mask_img.mode != 'L':
        mask_img = mask_img.convert('L')
    
    # Convertir en tableau numpy
    mask = np.array(mask_img)
    
    return mask

def lemmatize_text(text, stopwords=None):
    morph = pymorphy2.MorphAnalyzer()
    
    if isinstance(text, bytes):
        text = text.decode('utf-8')
    
    text = text.replace('—', ' ').replace('^', ' ')
    words = [word.strip('.,!?()[]1234567890') for word in text.split()]
    words = [word for word in words if word and not word.isdigit()]
    
    lemmatized_words = []
    for word in words:
        try:
            lemma = morph.parse(word)[0].normal_form
            if lemma and len(lemma) > 1 and (not stopwords or lemma.lower() not in stopwords):
                lemmatized_words.append(lemma)
        except:
            continue
    
    return ' '.join(lemmatized_words)

def main(args, text, imagefile):
    """
    Fonction principale qui traite le texte et génère le nuage de mots.
    """
    # Charger les stopwords si spécifiés
    stopwords = None
    if 'stopwords_path' in args:
        stopwords = load_stopwords(args['stopwords_path'])
    
    # Lecture du fichier texte
    if hasattr(text, 'read'):
        try:
            content = text.read()
            if isinstance(content, bytes):
                content = content.decode('utf-8')
        except UnicodeDecodeError:
            content = content.decode('cp1251')
    else:
        content = text
    
    # Lemmatiser le texte avec les stopwords
    lemmatized_text = lemmatize_text(content.lower(), stopwords)
    
    # Préparer les paramètres pour WordCloud
    wordcloud_params = {
        'width': args.get('width', 800),
        'height': args.get('height', 400),
        'background_color': args.get('background', 'white'),
        'regexp': r"\w+",
        'prefer_horizontal': float(args.get('prefer_horizontal', 0.7)),
        'scale': float(args.get('scale', 1.2))
    }
    
    # Charger le masque si spécifié
    if 'mask_path' in args:
        mask = load_mask(args['mask_path'])
        wordcloud_params['mask'] = mask
    
    # Créer et générer le nuage de mots
    wordcloud = wc.WordCloud(**wordcloud_params)
    wordcloud.generate(lemmatized_text)
    image = wordcloud.to_image()

    # Sauvegarder l'image
    with imagefile:
        image.save(imagefile, format='png', optimize=True)

def extended_parse_args(args):
    """
    Extension de la fonction parse_args pour gérer nos paramètres personnalisés.
    
    Args:
        args: Liste des arguments de la ligne de commande
        
    Returns:
        Tuple contenant (arguments parsés, texte, fichier image)
    """
    args_copy = list(args)
    
    # Gérer les arguments personnalisés
    custom_args = {}
    i = 0
    while i < len(args_copy):
        if args_copy[i] == '--mask' and i + 1 < len(args_copy):
            custom_args['mask_path'] = args_copy[i + 1]
            args_copy.pop(i)
            args_copy.pop(i)
        elif args_copy[i] == '--stopwords' and i + 1 < len(args_copy):
            custom_args['stopwords_path'] = args_copy[i + 1]
            args_copy.pop(i)
            args_copy.pop(i)
        else:
            i += 1
    
    # Utiliser le parse_args original pour les autres arguments
    parsed_args, text, image = parse_args(args_copy)
    
    # Ajouter les arguments personnalisés
    parsed_args.update(custom_args)
    
    return parsed_args, text, image

if __name__ == "__main__":
    args, text, image = extended_parse_args(sys.argv[1:])
    main(args, text, image)