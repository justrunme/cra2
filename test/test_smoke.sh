#!/bin/bash
set -e

echo "🧪 Running smoke test..."

REPO_PATH="$(cd "$(dirname "$0")/.."; pwd)/create-repo"

if [ ! -x "$REPO_PATH" ]; then
  echo "❌ create-repo not found or not executable at $REPO_PATH"
  exit 1
fi

if ! "$REPO_PATH" --version | grep -q "create-repo v"; then
  echo "❌ version output not matched"
  exit 1
fi

echo "✅ Smoke test passed"
