import wordcloud as wc
import wordcloud.wordcloud_cli
from wordcloud.wordcloud_cli import parse_args
import sys

def main(args, text, imagefile):
    wordcloud = wc.WordCloud(**args)
    wordcloud.generate(text.lower())
    image = wordcloud.to_image()

    with imagefile:
        image.save(imagefile, format='png', optimize=True)

args, text, image = parse_args(sys.argv[1:])
main(args, text, image)
