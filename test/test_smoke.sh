#!/bin/bash
set -e

echo "🧪 Running smoke test..."

# Проверка наличия исполняемого файла
if [ ! -x "./create-repo" ]; then
  echo "❌ create-repo not found or not executable"
  exit 1
fi

# Проверка версии
if ! ./create-repo --version | grep -qE '^create-repo v[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "❌ version output not matched"
  exit 1
fi

echo "✅ Smoke test passed"
