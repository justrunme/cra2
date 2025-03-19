#!/bin/bash
set -e

echo "🧪 Running smoke test..."

# Путь к скрипту относительно текущей папки test/
REPO="../create-repo"

if [ ! -x "$REPO" ]; then
  echo "❌ create-repo not found or not executable at $REPO"
  exit 1
fi

if ! "$REPO" --version | grep -q "create-repo v"; then
  echo "❌ version output not matched"
  exit 1
fi

echo "✅ Smoke test passed"
