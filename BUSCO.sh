#!/bin/bash

INPUT="<input_directory>"
OUTPUT="<output_directory>"

DATABASE=apicomplexa_odb10

for f in "$INPUT"/*.fna; do
    name=$(basename "$f" .fna)

    busco \
        -i "$f" \
        -l "$DATABASE" \
        -o "$OUTPUT/${name}_busco" \
        -m genome
done
