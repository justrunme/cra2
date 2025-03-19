#!/bin/bash
set -e

echo "🧪 Running smoke test..."

if ! command -v create-repo &>/dev/null; then
  echo "❌ create-repo not found in PATH"
  exit 1
fi

if ! create-repo --version | grep -q "create-repo v"; then
  echo "❌ version output not matched"
  exit 1
fi

echo "✅ Smoke test passed"
