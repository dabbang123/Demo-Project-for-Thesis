#!/usr/bin/env bash
set -euo pipefail
TARGET_PATH="${WORKSPACE:-$(pwd)}"
echo "[03] Trivy filesystem scan at: ${TARGET_PATH}"
mkdir -p reports
trivy fs \
  --format json \
  --output reports/trivy-fs.json \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  "${TARGET_PATH}"
