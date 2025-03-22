#!/bin/bash
set -e

echo "🧪 Testing auto-sync and cron integration..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

# Создаем временную директорию
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Удалим старые следы
rm -f ~/.repo-autosync.list ~/.create-repo.log ~/.create-repo.conf ~/.create-repo.platforms

# Создаем конфиг заранее, чтобы избежать интерактива
echo "default_branch=main" > ~/.create-repo.conf

# Создаем пустой файл автосинхронизации (нужно для dry-run)
touch ~/.repo-autosync.list

# Создаем dummy git репозиторий
git init -b main &>/dev/null
echo "# Auto-sync test" > README.md
git add README.md
git config user.email "ci@example.com"
git config user.name "CI User"
git commit -m "init" &>/dev/null

# Добавим фейковый origin
git remote add origin https://example.com/fake.git

# Диагностика перед запуском
echo "ℹ️ git status:"
git status
echo "ℹ️ current branch:"
git branch
echo "ℹ️ git remote -v:"
git remote -v

# Запускаем create-repo в dry-run режиме
echo "▶️ Running create-repo with --dry-run..."
"$BIN" --dry-run > create-repo-output.log 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "❌ create-repo failed with exit code $EXIT_CODE. Output:"
  cat create-repo-output.log || echo "(log missing)"
  exit 1
fi

# Проверяем запись в .repo-autosync.list
if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not found in ~/.repo-autosync.list"
  echo "📝 Contents of ~/.repo-autosync.list:"
  cat ~/.repo-autosync.list || echo "(empty)"
  exit 1
fi
echo "✅ Repo added to autosync list"

# Добавляем файл и коммитим (без пуша)
echo "Test $(date)" > test-sync.txt
git add test-sync.txt
git commit -m "Test auto-sync" &>/dev/null

# Запускаем update-all
echo "▶️ Running update-all..."
UPDATE_LOG=$(mktemp)
NO_PUSH=true update-all --pull-only > "$UPDATE_LOG" 2>&1 || {
  echo "❌ update-all failed:"
  cat "$UPDATE_LOG"
  exit 1
}

# Проверяем наличие git pull
if ! grep -qi "pull" "$UPDATE_LOG"; then
  echo "❌ update-all log does not contain 'pull':"
  cat "$UPDATE_LOG"
  exit 1
fi
echo "✅ update-all ran successfully with git pull"

echo "✅ Auto-sync and cron integration test passed"
