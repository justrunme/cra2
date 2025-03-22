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
git config user.email "ci@example.com"
touch file.txt
git add file.txt
git commit -m "Initial commit"

# 🔁 Добавим фейковый remote и установим upstream
git remote add origin .
git branch --set-upstream-to=origin/master master

# Запуск команды
if "$BIN" --sync-now; then
  echo "✅ --sync-now test passed"
else
  echo "❌ --sync-now failed"
  exit 1
fi
