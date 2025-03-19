#!/bin/bash
set -e

echo "🧪 Running smoke test..."

cd "$(dirname "$0")"
REPO="../create-repo"

if [ ! -x "$REPO" ]; then
  echo "❌ create-repo not found at $REPO"
  exit 1
fi

if ! "$REPO" --version | grep -q "create-repo v"; then
  echo "❌ version output not matched"
  exit 1
fi

echo "✅ Smoke test passed"
