#!/bin/bash

FONT_SIZE=120
FONT_FAMILY=Monaco
STYLE=solarizedlight
OUTPUT=rtf

FILENAME="$1"

if [[ -z "$FILENAME" ]]; then
  >&2 echo 'Please supply filename'
  exit 1
fi

pygmentize -f "$OUTPUT" -O "style=$STYLE,fontface=$FONT_FAMILY,fontsize=$FONT_SIZE" "$FILENAME" | pbcopy
