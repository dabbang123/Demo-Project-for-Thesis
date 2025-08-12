#!/usr/bin/env bash
set -euo pipefail
echo "[03] Trivy filesystem scan"
mkdir -p reports
trivy fs --format json --output reports/trivy-fs.json \
  --severity HIGH,CRITICAL --exit-code 1 