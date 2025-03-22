#!/bin/bash
set -e
set -x
trap 'echo "❌ FAILED at line $LINENO with exit code $?"' ERR

echo "🧪 Testing local config override..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
SCRIPT_DIR="$(dirname "$BIN")"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Инициализация git-репозитория
git init -b main &>/dev/null
echo "# Test override" > README.md
git add README.md
git config user.email "ci@example.com"
git config user.name "CI User"
git commit -m "init" &>/dev/null
git remote add origin https://example.com/fake.git

# Создаём local override
echo "disable_sync=true" > .create-repo.local.conf

# Запускаем create-repo в dry-run режиме
"$BIN" --dry-run --platform=github

# Проверяем, что путь записался в список
if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not tracked in ~/.repo-autosync.list"
  exit 1
fi

# Запускаем update-all и логируем вывод
UPDATE_LOG=$(mktemp)
NO_PUSH=true "$SCRIPT_DIR/update-all" > "$UPDATE_LOG" 2>&1

# Проверяем, что репозиторий был пропущен
if ! grep -q "skipped" "$UPDATE_LOG"; then
  echo "❌ Local config override not respected"
  cat "$UPDATE_LOG"
  exit 1
fi

echo "✅ Local config override test passed"
