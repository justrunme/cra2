#!/bin/bash
set -e

echo "🧪 Testing --help..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
OUTPUT=$("$BIN" --help || true)

if echo "$OUTPUT" | grep -q "Usage:"; then
  echo "✅ Help test passed"
else
  echo "❌ Help output missing"
  exit 1
fi
