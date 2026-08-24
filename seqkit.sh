#!/bin/bash

INPUT="<input_file>"
OUTPUT="<outpit_directory>"

seqkit stats "$INPUT"/*.fna > "$OUTPUT/genome_stats_seqkit.txt"
