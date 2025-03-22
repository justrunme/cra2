#!/bin/bash
set -e

echo "🧪 Testing --remove and --remove --force..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

# Добавляем в автосинк
"$BIN" --platform=github

# Проверяем, что путь добавлен в список
if ! grep -Fxq "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not added to ~/.repo-autosync.list"
  exit 1
fi

# Пробуем удалить без --force — не должно сработать
"$BIN" --remove || echo "⚠️ Expected failure for --remove without --force"

# Удаляем с --force
"$BIN" --remove --force

# Проверка, что удалено
if grep -Fxq "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not removed from ~/.repo-autosync.list"
  exit 1
fi

echo "✅ Remove test passed"
