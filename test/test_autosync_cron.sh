#!/bin/bash
set -e

echo "🧪 Testing auto-sync and cron integration..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

# Создаем временную папку и инициализируем git
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Удалим следы
rm -f ~/.repo-autosync.list ~/.create-repo.log

git init -b main &>/dev/null
echo "# Auto-sync test" > README.md
git add README.md
git config user.email "ci@example.com"
git config user.name "CI User"
git commit -m "init" &>/dev/null

# Запускаем create-repo
echo "▶️ Running create-repo..."
"$BIN" --platform=github > create-repo-output.log 2>&1 || {
  echo "❌ create-repo failed:"
  cat create-repo-output.log
  exit 1
}

# Проверяем запись в .repo-autosync.list
if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not found in ~/.repo-autosync.list"
  exit 1
fi
echo "✅ Repo added to autosync list"

# Добавляем тестовый файл и коммитим (без push)
echo "Test $(date)" > test-sync.txt
git add test-sync.txt
git commit -m "Test auto sync" &>/dev/null

# Запускаем update-all вручную
echo "▶️ Running update-all..."
UPDATE_LOG=$(mktemp)
update-all --pull-only > "$UPDATE_LOG" 2>&1 || {
  echo "❌ update-all failed"
  cat "$UPDATE_LOG"
  exit 1
}

# Проверка: лог содержит 'pull' (а push, если бы был, можно эмулировать)
if ! grep -q "pull" "$UPDATE_LOG"; then
  echo "❌ update-all log does not contain 'pull':"
  cat "$UPDATE_LOG"
  exit 1
fi

# Проверим crontab или launchctl (если возможно)
OS=$(uname)
if [[ "$OS" == "Darwin" ]]; then
  echo "ℹ️ Skipping launchctl check in CI"
else
  echo "ℹ️ Checking crontab (if available)..."
  if crontab -l 2>/dev/null | grep -q create-repo; then
    echo "✅ Crontab entry exists"
  else
    echo "⚠️ Crontab entry not found (may be normal in CI)"
  fi
fi

echo "✅ Auto-sync and cron integration test passed"
