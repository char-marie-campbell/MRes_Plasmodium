#=======================================================================
# R Script Name: Generation of NJ trees
# Author: Charlotte Campbell
# Purpose: To build NJ trees from each method - SKA2 (k=17, 31, 41),
# NUCmer, PopPUNK, and badread data
#=======================================================================
#-----------------------
# Libraries and options
#-----------------------
library(ape)

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------
# Convert pairwise distances into matrix
build_distance_matrix <- function(data,
                                  sample1_col,
                                  sample2_col,
                                  distance_col) {

  ids <- unique(c(
    data[[sample1_col]],
    data[[sample2_col]]
  ))

  mat <- matrix(
    NA,
    nrow = length(ids),
    ncol = length(ids),
    dimnames = list(ids, ids)
  )

  for (i in seq_len(nrow(data))) {

    sample_1 <- data[[sample1_col]][i]
    sample_2 <- data[[sample2_col]][i]
    distance <- data[[distance_col]][i]

    mat[sample_1, sample_2] <- distance
    mat[sample_2, sample_1] <- distance
  }

  diag(mat) <- 0

  mat
}
# Build neighbour-joining tree from pairwise distance file
build_nj_tree <- function(csv_file,
                          sample1_col,
                          sample2_col,
                          distance_col) {

  df <- read.csv(csv_file, stringsAsFactors = FALSE)

  dist_matrix <- build_distance_matrix(
    data = df,
    sample1_col = sample1_col,
    sample2_col = sample2_col,
    distance_col = distance_col
  )

  distance_object <- as.dist(dist_matrix)

  nj(distance_object)
}
# ------------------------------------------------------------
# File locations
# ------------------------------------------------------------
data_dir <- "data"
results_dir <- "results"

if (!dir.exists(results_dir)) {
  dir.create(results_dir)
}
# ------------------------------------------------------------
# SKA2 (k = 31)
# ------------------------------------------------------------
ska31_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "ska2_clean.csv"),
  sample1_col = "Sample1",
  sample2_col = "Sample2",
  distance_col = "Distance"
)

write.tree(
  ska31_tree,
  file.path(results_dir, "ska31_tree.nwk")
)
# ------------------------------------------------------------
# SKA2 (k = 17)
# ------------------------------------------------------------
ska17_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "plas_distance17_clean.csv"),
  sample1_col = "Sample1",
  sample2_col = "Sample2",
  distance_col = "Distance"
)

write.tree(
  ska17_tree,
  file.path(results_dir, "ska17_tree.nwk")
)
# ------------------------------------------------------------
# SKA2 (k = 41)
# ------------------------------------------------------------
ska41_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "plas_distance41_clean.csv"),
  sample1_col = "Sample1",
  sample2_col = "Sample2",
  distance_col = "Distance"
)

write.tree(
  ska41_tree,
  file.path(results_dir, "ska41_tree.nwk")
)
# ------------------------------------------------------------
# NUCmer
# ------------------------------------------------------------
nucmer_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "cleaneddnadiff.csv"),
  sample1_col = "Sample",
  sample2_col = "Reference",
  distance_col = "SNP_distance"
)

write.tree(
  nucmer_tree,
  file.path(results_dir, "nucmer_tree.nwk")
)
# ------------------------------------------------------------
# PopPUNK
# ------------------------------------------------------------
poppunk_tree <- build_nj_tree(
  csv_file = file.path(
    data_dir,
    "database_k21_41_s100k_distances.csv"
  ),
  sample1_col = "Query",
  sample2_col = "Reference",
  distance_col = "Core"
)

write.tree(
  poppunk_tree,
  file.path(results_dir, "poppunk_tree.nwk")
)
# ------------------------------------------------------------
# Badread SKA2
# ------------------------------------------------------------
badread_ska2_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "badread_ska2.csv"),
  sample1_col = "Sample1",
  sample2_col = "Sample2",
  distance_col = "Distance"
)

write.tree(
  badread_ska2_tree,
  file.path(results_dir, "badread_ska2_tree.nwk")
)
# ------------------------------------------------------------
# Badread PopPUNK
# ------------------------------------------------------------
badread_poppunk_tree <- build_nj_tree(
  csv_file = file.path(data_dir, "badread_poppunk.csv"),
  sample1_col = "Query",
  sample2_col = "Reference",
  distance_col = "Core"
)

write.tree(
  badread_poppunk_tree,
  file.path(results_dir, "badread_poppunk_tree.nwk")
)
