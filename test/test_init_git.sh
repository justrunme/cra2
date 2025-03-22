#!/bin/bash
set -e

echo "🧪 Testing git init in non-interactive mode..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Очистка предыдущих следов
rm -f "$HOME/.repo-autosync.list" "$HOME/.create-repo.log"

# Минимальные настройки git
git config --global user.email "ci@local.test"
git config --global user.name "CI Bot"

# Запускаем create-repo с dry-run
"$BIN" my-test-repo --platform=github --dry-run

# Проверки
echo "🔍 Проверка наличия .git"
if [ ! -d ".git" ]; then
  echo "❌ .git not initialized"
  exit 1
fi

echo "🔍 Проверка наличия ~/.repo-autosync.list"
if [ ! -f "$HOME/.repo-autosync.list" ]; then
  echo "❌ .repo-autosync.list not created"
  exit 1
fi

echo "🔍 Проверка трекинга текущего пути"
if ! grep -q "$TMP_DIR" "$HOME/.repo-autosync.list"; then
  echo "❌ Repo path not tracked"
  exit 1
fi

echo "🔍 Проверка наличия лога"
if [ ! -f "$HOME/.create-repo.log" ]; then
  echo "❌ Log file not created"
  exit 1
fi

echo "✅ Git init (non-interactive) test passed"
