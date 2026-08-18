#!/bin/bash

INPUT="/mnt/scratch2/charlotte/plasmodiumGenomes"
OUTPUT="/mnt/scratch2/charlotte"

seqkit stats "$INPUT"/*.fna > "$OUTPUT/genome_stats_seqkit.txt"