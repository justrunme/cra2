#!/bin/bash
set -e
set -x
trap 'code=$?; echo "❌ FAILED at line $LINENO with exit code $code" >&2; exit $code' ERR

echo "🧪 Testing auto-sync and cron integration..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
SCRIPT_DIR="$(dirname "$BIN")"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Очистка старых конфигов
rm -f ~/.repo-autosync.list ~/.create-repo.log ~/.create-repo.conf ~/.create-repo.platforms

# Минимальный глобальный конфиг
echo "platform=github" > ~/.create-repo.conf
touch ~/.repo-autosync.list

# Создаём dummy git-репозиторий
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

# Запускаем create-repo с dry-run
echo "▶️ Running create-repo with --dry-run..."
NO_PUSH=true "$BIN" --dry-run > create-repo-output.log 2>&1 || {
  echo "❌ create-repo failed. Output:"
  cat create-repo-output.log
  exit 1
}

echo "✅ create-repo ran in dry-run mode successfully"

# Добавим файл для sync
echo "Test $(date)" > test-sync.txt
git add test-sync.txt
git commit -m "Test auto-sync" &>/dev/null

# Запускаем update-all
echo "▶️ Running update-all..."
UPDATE_LOG=$(mktemp)
chmod +x "$SCRIPT_DIR/update-all"
echo "ℹ️ Using update-all at: $SCRIPT_DIR/update-all"

NO_PUSH=true "$SCRIPT_DIR/update-all" --pull-only > "$UPDATE_LOG" 2>&1 || {
  if grep -q "example.com/fake.git" "$UPDATE_LOG"; then
    echo "⚠️ Fake remote failed as expected (example.com)."
  else
    echo "❌ update-all failed:"
    cat "$UPDATE_LOG"
    exit 1
  fi
}

# Проверка: лог должен содержать 'Pulling'
if ! grep -q "Pulling" "$UPDATE_LOG"; then
  echo "❌ update-all log does not contain 'Pulling':"
  cat "$UPDATE_LOG"
  exit 1
fi

echo "✅ Auto-sync and cron integration test passed"
exit 0
