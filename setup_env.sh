#!/usr/bin/env bash
# One-shot environment bootstrap. See CONTEXT_TRANSFER.md §2 for the reasoning behind each step.
set -euo pipefail

ENV_NAME="nerfstudio"

echo "==> Accepting conda ToS for default channels (required on recent conda)"
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

echo "==> Creating conda env '${ENV_NAME}' with Python 3.10"
conda create --name "${ENV_NAME}" -y python=3.10

# shellcheck disable=SC1091
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "${ENV_NAME}"

echo "==> Upgrading pip"
python -m pip install --upgrade pip

echo "==> Installing CUDA-enabled torch (must happen before nerfstudio — see §5.2)"
pip install torch==2.2.0 torchvision --index-url https://download.pytorch.org/whl/cu121

echo "==> Installing nerfstudio"
pip install nerfstudio

echo "==> Installing COLMAP < 3.10 from conda-forge (avoids CLI flag rename in 3.13+, see §5.3)"
conda install -c conda-forge "colmap<3.10" -y

echo "==> Verifying installation"
python -c "import torch; print('torch:', torch.__version__, '| CUDA available:', torch.cuda.is_available())"
colmap --help | head -3

echo "==> Done. Activate with: conda activate ${ENV_NAME}"
