#!/bin/bash
set -e

echo "🚀 Deploying latest image..."

# Read image tag from file
FULL_TAG=$(cat image_tag.txt)

# Default port
HOST_PORT=8080

# Check if port is already in use
if lsof -i:${HOST_PORT} -t >/dev/null; then
  echo "⚠️ Port ${HOST_PORT} is busy, switching to ${HOST_PORT}+1"
  HOST_PORT=$((HOST_PORT + 1))
fi

# Stop and remove existing container if it exists
docker stop myapp >/dev/null 2>&1 || true
docker rm myapp >/dev/null 2>&1 || true

# Run container on the selected port
docker run -d --name myapp -p ${HOST_PORT}:8080 "${FULL_TAG}"

# Detect VM IP automatically
VM_IP=$(hostname -I | awk '{print $1}')

echo "✅ Deployment successful! Access the app at: http://${VM_IP}:${HOST_PORT}"
