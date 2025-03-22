#!/bin/bash
set -e

echo "🧪 Testing --version..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
OUTPUT=$("$BIN" --version)

echo "📤 Output: $OUTPUT"

if [[ "$OUTPUT" == *"version:"* ]]; then
  echo "✅ Version test passed"
else
  echo "❌ --version output incorrect"
  exit 1
fi
