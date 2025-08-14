# scripts/04_trivy_image_scan.sh
#!/usr/bin/env bash
set -euo pipefail
echo "[04] Trivy image scan"
mkdir -p reports
FULL_TAG="$(cat image_tag.txt)"           # produced by scripts/02_build_image.sh
trivy image \
  --format json \
  --output reports/trivy-image.json \
  --severity HIGH,CRITICAL \
  --exit-code 0 \            # scans should not fail the pipeline here; gating is later
  "${FULL_TAG}"
