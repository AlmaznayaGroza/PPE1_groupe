#!/bin/bash

INPUT=$1

python3 programmes/cooccurrents.py pals/contexte-ru.txt --target "(сознание|сознания|сознанию|сознанием|сознании|сознаний|сознаниям|сознаниями|сознаниях|совесть|совести|совестью|совестей|совестям|совестями|совестях)" --match-mode regex

