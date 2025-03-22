#!/bin/bash
set -e

echo "🧪 Testing git init..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TEMP_DIR=$(mktemp -d)
echo "📁 TEMP_DIR: $TEMP_DIR"

cd "$TEMP_DIR"

# Запускаем скрипт с автопотоком ввода
"$BIN" --interactive <<EOF
my-test-repo
n
EOF

# Показываем структуру директории после запуска
echo "📂 Contents of $TEMP_DIR:"
ls -la

# Проверяем наличие .git
if [ ! -d .git ]; then
  echo "❌ Git repo not initialized"
  exit 1
fi

echo "✅ Git init test passed"
