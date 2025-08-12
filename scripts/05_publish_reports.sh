#!/usr/bin/env bash
set -euo pipefail

echo "[05] Publishing security scan reports"

mkdir -p reports/html

# Convert Trivy FS JSON to a readable text summary
if [[ -f reports/trivy-fs.json ]]; then
    echo "[FS SCAN RESULTS]" > reports/fs-summary.txt
    jq '.Results[] | {Target, Vulnerabilities}' reports/trivy-fs.json >> reports/fs-summary.txt
fi

# Convert Trivy Image JSON to a readable text summary
if [[ -f reports/trivy-image.json ]]; then
    echo "[IMAGE SCAN RESULTS]" > reports/image-summary.txt
    jq '.Results[] | {Target, Vulnerabilities}' reports/trivy-image.json >> reports/image-summary.txt
fi

# Combine text files
cat reports/fs-summary.txt reports/image-summary.txt > reports/final-summary.txt

# Optional: Create HTML version (requires 'aha')
if command -v aha &> /dev/null; then
    cat reports/final-summary.txt | aha > reports/html/final-summary.html
    echo "HTML summary generated at reports/html/final-summary.html"
else
    echo "aha not installed, skipping HTML conversion"
fi
