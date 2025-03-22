#!/bin/bash
set -e

echo "🧪 Testing --platform override and --update..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

# Установка platform=github вручную
"$BIN" --platform=github

# Проверяем, что платформа сохранена
if ! grep -q "github" "$HOME/.create-repo.platforms"; then
  echo "❌ Platform override not saved to .create-repo.platforms"
  exit 1
fi

# Пробуем вызвать --update (может завершиться с ошибкой — допустимо)
"$BIN" --update || echo "⚠️ Update may fail without GitHub token (expected)"

echo "✅ Platform override test passed"
