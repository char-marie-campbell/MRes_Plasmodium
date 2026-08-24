#!/bin/bash

GENOME_IN="<input_directory>"
OUPUT="<output_directory>"

THREADS=2
KMER=17 #(41, 31)

cd "$GENOMES_IN" || {
    echo "Error: Cannot access $GENOME_IN"
    exit 1
}

#==Complete genome assembly file creation
for f in *.fna; do
    s=(basename "$f" .fna)
    echo -e "$s\t$(readlink -f "$f")"
done > "$OUTPUT/tab_assem.txt"

#==Building sketch
ska build \
    -o "$OUPUT/plasmodiumGenomes_k${KMER}" \
    -k "$KMER" \
    -f "$OUTPUT/tab_assem.txt" \
    --threads "$THREADS"

#==Building distances
ska distance \
    --threads "$THREADS" \
    -o "$OUTPUT/plas_distance${KMER}.txt" \
    "$OUTPUT/plasmodiumGenomes_k${KMER}.skf"
