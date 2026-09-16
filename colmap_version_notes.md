# COLMAP CLI Version Notes

COLMAP's command-line interface is not fully stable across versions. This project hit two
concrete breakages; documenting both here so they're not re-discovered the hard way.

## `SiftExtraction.use_gpu` → `FeatureExtraction.use_gpu`

| COLMAP version | GPU flags for `feature_extractor` |
|---|---|
| ≤ 3.9 | `--SiftExtraction.use_gpu`, `--SiftExtraction.gpu_index` |
| 3.13.0 (confirmed on this project) | `--FeatureExtraction.use_gpu`, `--FeatureExtraction.gpu_index` |

Everything else under `SiftExtraction.*` (max_image_size, peak_threshold, edge_threshold,
etc.) is unaffected — only the GPU toggle and index moved to a new `FeatureExtraction.*`
group. Nerfstudio 1.1.5's bundled `colmap_utils.py` still hardcodes the old name, which will
fail with:

```
Failed to parse options - unrecognised option '--SiftExtraction.use_gpu'.
```

on colmap 3.13+. Resolution used in this project: pin `colmap<3.10` via conda-forge rather
than patch nerfstudio's source.

## `colmap texture_mesh` does not exist

Not a real subcommand in mainline COLMAP at any version checked. The correct command is:

```
colmap mesh_texturer --workspace_path <dense_workspace> --input_path <mesh.ply> --output_path <out.obj>
```

## General practice going forward

Before trusting any colmap command (from docs, tutorials, or AI-generated snippets), verify
against the actually-installed binary:

```bash
colmap --help | head -3          # confirms version + whether CUDA-enabled
colmap <subcommand> --help       # confirms exact flag names for that version
```
