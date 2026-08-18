#!/bin/bash

INPUT="/mnt/scratch2/charlotte/plasmodiumGenomes"
OUTPUT="/mnt/scratch2/charlotte/badread_output"

COVERAGE="50x"
ERROR_MODEL="random"
QSCORE_MODEL="ideal"

GLITCHES="0,0,0"
JUNK="0"
RANDOM_READS="0"
CHIMERAS="0"

IDENTITY="30,3"
READ_LEN="40000,20000"

START_ADAPTER=""
END_ADAPTER=""

#==Read simulation
for ref in "$INPUT"/*.fna; do
    SAMPLE=$(basename "$ref" .fna)

    echo "Processing $SAMPLE"

    badread simulate \
        --reference "$ref" \
        --quantity "$COVERAGE" \
        --error_model "$ERROR_MODEL" \
        --qscore_model "$QSCORE_MODEL" \
        --glitches "$GLITCHES" \
        --junk_reads "$JUNK_READS" \
        --random_reads "$RANDOM_READS" \
        --chimeras "$CHIMERAS" \
        --identity "$IDENTITY" \
        --length "$READ_LEN" \
        --start_adapter_seq "$START_ADAPTER" \
        --end_adapter_seq "$END_ADAPTER" \
    | gzip > "$OUPUT/${SAMPLE}_reads.fastq.gz"
done