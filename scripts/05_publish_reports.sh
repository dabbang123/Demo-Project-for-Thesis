#!/usr/bin/env bash
set -euo pipefail
echo "[05] Human-readable summaries"
mkdir -p reports/html
trivy fs --severity MEDIUM,HIGH,CRITICAL --format table . > reports/html/trivy-fs.txt || true
FULL_TAG="$(cat image_tag.txt)"
trivy image --severity MEDIUM,HIGH,CRITICAL --format table "${FULL_TAG}" > reports/html/trivy-image.txt || true