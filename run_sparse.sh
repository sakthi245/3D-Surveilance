#!/usr/bin/env bash
# Video -> COLMAP sparse reconstruction, via nerfstudio's ns-process-data.
# See CONTEXT_TRANSFER.md §5.1 for capture requirements (real camera translation, not just
# rotation) and §6.1 for the command this wraps.
set -euo pipefail

VIDEO_PATH="${1:?Usage: run_sparse.sh <path-to-video.mp4> [output-dir] [num-frames-target]}"
OUTPUT_DIR="${2:-./nerf_data/processed}"
NUM_FRAMES="${3:-200}"

ns-process-data video \
  --data "${VIDEO_PATH}" \
  --output-dir "${OUTPUT_DIR}" \
  --num-frames-target "${NUM_FRAMES}"

echo "==> Done. Checking reconstruction quality:"
colmap model_analyzer --path "${OUTPUT_DIR}/colmap/sparse/0"
