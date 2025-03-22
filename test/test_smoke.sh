#!/bin/bash
set -e

echo "🧪 Running smoke test..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
output=$("$BIN" --version)

echo "📤 Output: $output"

if [[ "$output" == *"version:"* && "$output" != *"{{VERSION}}"* && "$output" != *"unknown"* ]]; then
  echo "✅ Smoke test passed"
else
  echo "❌ version output not matched: $output"
  exit 1
fi
