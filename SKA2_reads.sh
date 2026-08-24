#!/bin/bash

READS_IN="<input_directory>"
OUT_DIR="<output_directory"

THREADS=2
KMER=17

cd "$READS_IN" || {
    echo "Error: Cannot access $READS_IN"
    exit 1
}

#==Creating read assembly file
for f in *.fastq.gz; do
    s=$(basename "$f" .fastq.gz)
    echo -e "$s\t$(readlink -f "$f")"
done > "$OUT_DIR/badread_assemblies.txt"

#==Building sketch
ska build \
    -o "$OUT_DIR/badread_k${KMER}" \
    -k "$KMER" \
    -f "$OUT_DIR/badread_assemblies.txt" \
    --threads "$THREADS"

#==Building distances
ska distance \
    --threads "$THREADS" \
    -o "$OUT_DIR/rawread_${KMER}.txt \
    "$OUT_DIR/badread_k${KMER}.skf"
