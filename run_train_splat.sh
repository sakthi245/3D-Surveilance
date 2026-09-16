#!/usr/bin/env bash
# Train a Gaussian Splatting scene from an existing sparse reconstruction.
# Requires: an output-dir already produced by run_sparse.sh (must contain transforms.json).
# See CONTEXT_TRANSFER.md §5.6 — splatfacto initializes from the sparse point cloud, NOT
# from any dense MVS output. Dense MVS (run_dense_mesh.sh) is an independent, parallel path.
set -euo pipefail

DATA_DIR="${1:?Usage: run_train_splat.sh <processed-data-dir> [output-dir]}"
OUTPUT_DIR="${2:-./output}"

ns-train splatfacto \
  --data "${DATA_DIR}" \
  --output-dir "${OUTPUT_DIR}" \
  --max-num-iterations 30000 \
  --pipeline.model.background-color white \
  --pipeline.model.random-scale 0.0

# If you hit a CUDA out-of-memory error on a GPU with <=6GB VRAM, rerun with:
#   --pipeline.datamanager.train-num-rays-per-batch 2048
