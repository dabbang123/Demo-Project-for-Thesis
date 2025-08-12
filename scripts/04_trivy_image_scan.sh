#!/usr/bin/env bash
set -euo pipefail
echo "[04] Trivy image scan"
mkdir -p reports
FULL_TAG="$(cat image_tag.txt)"
trivy image --format json --output reports/trivy-image.json \
  --severity HIGH,CRITICAL --exit-code 1 "${FULL_TAG}"