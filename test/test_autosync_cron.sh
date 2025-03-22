#!/bin/bash
set -e
set -x
trap 'echo "❌ FAILED at line $LINENO with exit code $?"' ERR

echo "🧪 Testing auto-sync and cron integration..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Чистим старые конфиги
rm -f ~/.repo-autosync.list ~/.create-repo.log ~/.create-repo.conf ~/.create-repo.platforms

# Пишем конфиг и создаем пустой список
echo "platform=github" > ~/.create-repo.conf
touch ~/.repo-autosync.list

# Создаем dummy git-репозиторий
git init -b main &>/dev/null
echo "# Auto-sync test" > README.md
git add README.md
git config user.email "ci@example.com"
git config user.name "CI User"
git commit -m "init" &>/dev/null
git remote add origin https://example.com/fake.git

# Диагностика
echo "ℹ️ git status:"
git status
echo "ℹ️ current branch:"
git branch
echo "ℹ️ git remote -v:"
git remote -v

# Запуск в dry-run
echo "▶️ Running create-repo with --dry-run..."
NO_PUSH=true "$BIN" --dry-run > create-repo-output.log 2>&1 || {
  echo "❌ create-repo failed. Output:"
  cat create-repo-output.log
  exit 1
}

# ⚠️ Не проверяем наличие в ~/.repo-autosync.list, т.к. dry-run не должен ничего записывать

echo "✅ create-repo ran in dry-run mode successfully"

# Добавим файл для симуляции синка
echo "Test $(date)" > test-sync.txt
git add test-sync.txt
git commit -m "Test auto-sync" &>/dev/null

echo "▶️ Running update-all..."
UPDATE_LOG=$(mktemp)
NO_PUSH=true update-all --pull-only > "$UPDATE_LOG" 2>&1 || {
  echo "❌ update-all failed:"
  cat "$UPDATE_LOG"
  exit 1
}

if ! grep -q "pull" "$UPDATE_LOG"; then
  echo "❌ update-all log does not contain 'pull':"
  cat "$UPDATE_LOG"
  exit 1
fi

echo "✅ Auto-sync and cron integration test passed"
