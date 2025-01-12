import spacy
import fileinput

# Charger le modèle russe
nlp = spacy.load("ru_core_news_md")
nlp.disable_pipes("parser", "attribute_ruler", "ner")
nlp.enable_pipe("senter")
for line in fileinput.input():
    doc = nlp(line)
    for sent in doc.sents:
        print(" ".join([f"{tok.text}_{tok.lemma}_{tok.pos_}" for tok in sent]))

# # Texte à analyser
# text = "Собака бежала по улице. Она лаяла на прохожих."

# # Analyse du texte
# doc = nlp(text)

# # Affichage des tokens, lemmes et parties du discours
# for token in doc:
#     print(f"Texte : {token.text}, Lemma : {token.lemma_}, POS : {token.pos_}")

# # Extraction des entités nommées
# print("\nEntités nommées :")
# for ent in doc.ents:
#     print(f"Texte : {ent.text}, Label : {ent.label_}")
