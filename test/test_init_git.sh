#!/bin/bash
set -e

echo "🧪 Testing git init in non-interactive mode..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Запускаем create-repo с минимальными аргументами
"$BIN" my-test-repo --platform=github --dry-run

# Проверки
if [ ! -d ".git" ]; then
  echo "❌ .git not initialized"
  exit 1
fi

if [ ! -f "$HOME/.repo-autosync.list" ]; then
  echo "❌ .repo-autosync.list not created"
  exit 1
fi

if ! grep -q "$TMP_DIR" "$HOME/.repo-autosync.list"; then
  echo "❌ Repo path not tracked"
  exit 1
fi

if [ ! -f "$HOME/.create-repo.log" ]; then
  echo "❌ Log file not created"
  exit 1
fi

echo "✅ Git init (non-interactive) test passed"
