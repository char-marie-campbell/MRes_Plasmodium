#!/bin/bash

INPUT_FILE="/mnt/scratch2/charlotte/plasmodiumGenomes/tab_assem.txt"
OUTPUT="/mnt/scratch2/charlotte/poppunk_output"

MIN_K=29
MAX_K=61
KSTEP=8
SKETCH_SIZE=100000
THREADS=8

RUN_NAME="poppunk_k${MIN_K}_${MAX_K}_s100k"

#==Create the database
poppunk \
    --create-db \
    --r-files "$INPUT_FILE" \
    --min-k "$MIN_K" \
    --max-k "$MAX_K" \
    --k-step "$KSTEP" \
    --output "$OUTPUT/$RUN_NAME" \
    --sketch-size "$SKETCH_SIZE" \
    --threads "$THREADS"

#==Extract distances
poppunk_extract_distances.py \
    --distances "$OUTPUT/$RUN_NAME/${RUN_NAME}.dists" \
    --output "$OUTPUT/${RUN_NAME}_distances.tsv"