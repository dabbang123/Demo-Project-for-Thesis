# #!/usr/bin/env bash
# set -euo pipefail
# echo "[02] Docker build"
# IMAGE_NAME="${IMAGE_NAME:-local/demo-thesis}"
# GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)"
# IMAGE_TAG="${IMAGE_TAG:-$GIT_SHA}"
# FULL_TAG="${IMAGE_NAME}:${IMAGE_TAG}"
# docker build --pull -t "${FULL_TAG}" .
# echo "${FULL_TAG}" > image_tag.txt
# echo "[OK] Built ${FULL_TAG}"
#!/usr/bin/env bash
set -euo pipefail
echo "[02] Docker build"

IMAGE_NAME="hello-world"
IMAGE_TAG="v1"
FULL_TAG="${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${FULL_TAG}" .

# Save tag for later stages
echo "${FULL_TAG}" > image_tag.txt
