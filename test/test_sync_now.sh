#!/bin/bash
set -e

echo "🧪 Testing --sync-now command..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
TMP_DIR=$(mktemp -d)
echo "📁 TMP_DIR: $TMP_DIR"
cd "$TMP_DIR"

# Инициализация git
git init
git config user.name "CI Bot"
git config user.email "ci@local.test"
touch file.txt
git add .
git commit -m "Initial commit"
git remote add origin https://example.com/fake.git

# ✅ Установка upstream, чтобы pull не падал
git branch --set-upstream-to=origin/master master || true

# Тестируем команду
if "$BIN" --sync-now; then
  echo "✅ --sync-now test passed"
else
  echo "❌ --sync-now failed"
  exit 1
fi
