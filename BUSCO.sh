#!/bin/bash

INPUT="/mnt/scratch2/charlotte/plasmodiumGenomes"
OUTPUT="/mnt/scratch2/charlotte/busco_genomic_outputs"

DATABASE=apicomplexa_odb10

for f in "$INPUT"/*.fna; do
    name=$(basename "$f" .fna)

    busco \
        -i "$f" \
        -l "$DATABASE" \
        -o "$OUTPUT/${name}_busco" \
        -m genome
done