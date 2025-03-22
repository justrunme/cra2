#!/bin/bash
set -e

echo "🧪 Testing auto-sync and cron integration..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

# Создаем временную папку
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Удалим глобальные следы
rm -f ~/.repo-autosync.list

# Создаем dummy git репозиторий
git init -b main &>/dev/null
touch README.md
git add README.md
git config user.email "test@example.com"
git config user.name "Test User"
git commit -m "init" &>/dev/null

# Запускаем create-repo без --disable-sync
echo "▶️ Running create-repo to enable auto-sync..."

# Логируем вывод команды для диагностики
"$BIN" --platform=github || { 
  echo "❌ Failed to run create-repo. Here's the output of the failed command:" 
  "$BIN" --platform=github 
  exit 1 
}

# Проверяем .repo-autosync.list
echo "📂 Checking if repo was added to .repo-autosync.list..."
if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not added to ~/.repo-autosync.list"
  exit 1
fi
echo "✅ Repo added to autosync list"

# Проверяем запись в cron/launchctl
OS=$(uname)
if [[ "$OS" == "Darwin" ]]; then
  echo "📂 Checking for launchctl job..."
  JOBS=$(launchctl list | grep create-repo || true)
  if [[ -z "$JOBS" ]]; then
    echo "❌ No launchctl job found for create-repo"
    exit 1
  fi
  echo "✅ launchctl job found"
else
  echo "📂 Checking for cron job..."
  CRON=$(crontab -l 2>/dev/null | grep create-repo || true)
  if [[ -z "$CRON" ]]; then
    echo "❌ No crontab entry found for create-repo"
    exit 1
  fi
  echo "✅ Crontab entry found"
fi

echo "✅ Auto-sync and cron integration test passed"
