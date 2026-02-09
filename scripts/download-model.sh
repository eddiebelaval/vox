#!/bin/bash
# Download a whisper.cpp GGML model for Vox
# Usage: ./scripts/download-model.sh [model-name]
# Example: ./scripts/download-model.sh large-v3-turbo

set -euo pipefail

MODEL_NAME="${1:-large-v3-turbo}"
BASE_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"
MODELS_DIR="$(dirname "$0")/../Models"

mkdir -p "$MODELS_DIR"

FILENAME="ggml-${MODEL_NAME}.bin"
OUTPUT_PATH="${MODELS_DIR}/${FILENAME}"

if [ -f "$OUTPUT_PATH" ]; then
    echo "Model already exists: $OUTPUT_PATH"
    echo "Delete it first if you want to re-download."
    exit 0
fi

echo "Downloading ${FILENAME}..."
curl -L "${BASE_URL}/${FILENAME}" -o "$OUTPUT_PATH"

echo "Done! Model saved to: $OUTPUT_PATH"
echo "Size: $(du -h "$OUTPUT_PATH" | cut -f1)"
