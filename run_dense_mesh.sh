#!/usr/bin/env bash
# Sparse reconstruction -> dense MVS -> textured mesh (.obj).
# Independent of the splat/NeRF training path (run_train_splat.sh) — both consume the same
# sparse reconstruction but produce unrelated outputs. See CONTEXT_TRANSFER.md §5.5, §5.6, §6.4.
#
# IMPORTANT: before running, verify the mesh_texturer flags on your installed colmap version:
#   colmap mesh_texturer --help
# Flag names have changed between COLMAP versions before (see CONTEXT_TRANSFER.md §5.3-5.4)
# and this script may need adjusting if you're on a different version than 3.9.x.
set -euo pipefail

PROCESSED_DIR="${1:?Usage: run_dense_mesh.sh <processed-data-dir> [dense-dir] [mesh-dir]}"
DENSE_DIR="${2:-./dense}"
MESH_DIR="${3:-./mesh}"

SPARSE_MODEL="${PROCESSED_DIR}/colmap/sparse/0"
IMAGES_DIR="${PROCESSED_DIR}/images"

mkdir -p "${DENSE_DIR}" "${MESH_DIR}"

echo "==> 0. Undistorting images (required before dense MVS steps)"
colmap image_undistorter \
  --image_path "${IMAGES_DIR}" \
  --input_path "${SPARSE_MODEL}" \
  --output_path "${DENSE_DIR}" \
  --output_type COLMAP

echo "==> 1. Patch match stereo (depth maps, GPU)"
colmap patch_match_stereo \
  --workspace_path "${DENSE_DIR}" \
  --workspace_format COLMAP \
  --PatchMatchStereo.geom_consistency true \
  --PatchMatchStereo.gpu_index 0 \
  --PatchMatchStereo.max_image_size 3200 \
  --PatchMatchStereo.window_radius 11 \
  --PatchMatchStereo.num_samples 15 \
  --PatchMatchStereo.num_iterations 12 \
  --PatchMatchStereo.filter true \
  --PatchMatchStereo.filter_min_triangulation_angle 1.5

echo "==> 2. Stereo fusion (dense point cloud)"
colmap stereo_fusion \
  --workspace_path "${DENSE_DIR}" \
  --workspace_format COLMAP \
  --input_type geometric \
  --output_path "${DENSE_DIR}/fused.ply" \
  --StereoFusion.min_num_pixels 3 \
  --StereoFusion.max_depth_error 0.01 \
  --StereoFusion.max_normal_error 10.0

echo "==> 3. Poisson mesh reconstruction"
colmap poisson_mesher \
  --input_path "${DENSE_DIR}/fused.ply" \
  --output_path "${MESH_DIR}/mesh.ply" \
  --PoissonMesher.depth 10 \
  --PoissonMesher.trim 7

echo "==> 4. Texture mapping"
colmap mesh_texturer \
  --workspace_path "${DENSE_DIR}" \
  --input_path "${MESH_DIR}/mesh.ply" \
  --output_path "${MESH_DIR}/textured_mesh.obj"

echo "==> Done. Final deliverable: ${MESH_DIR}/textured_mesh.obj (keep its .mtl and texture image alongside it)"
