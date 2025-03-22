#!/bin/bash
set -e

echo "🧪 Running smoke test..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

if [ ! -x "$BIN" ]; then
  echo "❌ create-repo not found or not executable at $BIN"
  exit 1
fi

output="$($BIN --version)"
echo "📤 Output: $output"

if [[ "$output" != "create-repo version: v"* ]]; then
  echo "❌ version output not matched: $output"
  exit 1
fi

echo "✅ Smoke test passed"
