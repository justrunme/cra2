#!/bin/bash
set -e

echo "🧪 Testing --sync-now command..."

BIN="${CREATE_REPO_BIN:-./create-repo}"  # fallback

# Создадим временную директорию с git-репо
TMP_DIR=$(mktemp -d)
echo "📁 TMP_DIR: $TMP_DIR"
cd "$TMP_DIR"
git init -q
touch README.md
git add README.md
git commit -m "init" -q

# Проверим, что команда выполняется без ошибок
"$BIN" --sync-now || {
  echo "❌ --sync-now failed"
  exit 1
}

echo "✅ --sync-now test passed"
