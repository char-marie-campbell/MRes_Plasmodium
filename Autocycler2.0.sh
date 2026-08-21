#!/bin/bash

set -euo pipefail
shopt -s nullglob

INPUT="<input directory>"
AUTOCYCLER_MAIN="<output directory>"

SUBSAMPLE_COUNT=6
GENOME_SIZE="30m"
MIN_READ_DEPTH=30
THREADS=10

# ===================================================================
# Process all FASTQ files
# ===================================================================

for reads in "$INPUT"/*.fastq.gz; do

    GENOME=$(basename "$reads" .fastq.gz)

    echo "=================================================="
    echo "Processing $GENOME"
    echo "=================================================="

    GENOME_DIR="$AUTOCYCLER_MAIN/$GENOME"
    SUBSAMPLES_DIR="$GENOME_DIR/subsamples"
    ASSEMBLIES_DIR="$GENOME_DIR/assemblies"
    OUTPUT_DIR="$GENOME_DIR/autocycler_out"

    mkdir -p \
        "$GENOME_DIR" \
        "$SUBSAMPLES_DIR" \
        "$ASSEMBLIES_DIR" \
        "$OUTPUT_DIR"

    # ===============================================================
    # Stage 1: Subsampling
    # ===============================================================

    echo "Stage 1: Subsampling"

    autocycler subsample \
        --reads "$reads" \
        --out_dir "$SUBSAMPLES_DIR" \
        --count "$SUBSAMPLE_COUNT" \
        --genome_size "$GENOME_SIZE" \
        --min_read_depth "$MIN_READ_DEPTH"

    # ===============================================================
    # Stage 2: Assemblies
    # ===============================================================

    echo "Stage 2: Generating assemblies"

    for f in "$SUBSAMPLES_DIR"/*.fastq; do

        base=$(basename "$f" .fasta)

        echo "Assembling subsample: $base"

        # ---------------- Flye ----------------

        FLYE_DIR="$GENOME_DIR/flye_${base}"

        flye \
            --nano-raw "$f" \
            --out-dir "$FLYE_DIR" \
            --threads "$THREADS" \
            --genome-size "$GENOME_SIZE"

        if [[ -f "$FLYE_DIR/assembly.fasta" ]]; then
            cp \
                "$FLYE_DIR/assembly.fasta" \
                "$ASSEMBLIES_DIR/${base}_flye.fasta"
        else
            echo "WARNING: Flye assembly missing for $base"
        fi

        # ---------------- Raven ----------------

        raven \
            -t "$THREADS" \
            "$f" \
            > "$ASSEMBLIES_DIR/${base}_raven.fasta"

        # ---------------- Canu ----------------

        CANU_DIR="$GENOME_DIR/canu_${base}"

        canu \
            -p "${base}_canu" \
            -d "$CANU_DIR" \
            genomeSize="$GENOME_SIZE" \
            nanopore-raw="$f"

        if [[ -f "$CANU_DIR/${base}_canu.contigs.fasta" ]]; then
            cp \
                "$CANU_DIR/${base}_canu.contigs.fasta" \
                "$ASSEMBLIES_DIR/${base}_canu.fasta"
        else
            echo "WARNING: Canu assembly missing for $base"
        fi

    done

    # ===============================================================
    # Stage 3: Compress
    # ===============================================================

    echo "Stage 3: Compressing assemblies"

    autocycler compress \
        -i "$ASSEMBLIES_DIR" \
        -a "$OUTPUT_DIR" \
        -t "$THREADS"

    # ===============================================================
    # Stage 4: Cluster
    # ===============================================================

    echo "Stage 4: Clustering"

    autocycler cluster \
        -a "$OUTPUT_DIR"

    # ===============================================================
    # Stage 5: Trim
    # ===============================================================

    echo "Stage 5: Trimming clusters"

    for c in "$OUTPUT_DIR"/clustering/qc_pass/cluster_*; do
        [[ -d "$c" ]] || continue
        autocycler trim -c "$c"
    done

    # ===============================================================
    # Stage 6: Resolve
    # ===============================================================

    echo "Stage 6: Resolving clusters"

    for c in "$OUTPUT_DIR"/clustering/qc_pass/cluster_*; do
        [[ -d "$c" ]] || continue
        autocycler resolve -c "$c"
    done

    # ===============================================================
    # Stage 7: Combine
    # ===============================================================

    echo "Stage 7: Combining results"

    gfas=(
        "$OUTPUT_DIR"/clustering/qc_pass/cluster_*/5_final.gfa
    )

    if (( ${#gfas[@]} > 0 )); then

        autocycler combine \
            -a "$OUTPUT_DIR" \
            -i "${gfas[@]}"

    else
        echo "WARNING: No final GFA files found for $GENOME"
    fi

    echo "Completed: $GENOME"

done

echo "All genomes processed"
