#!/bin/bash
set -e
set -x

echo "🧪 Testing advanced local config usage..."

BIN="${CREATE_REPO_BIN:-create-repo}"
SCRIPT_DIR="$(dirname "$BIN")"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Инициализация
git init -b main &>/dev/null
git config user.email "ci@example.com"
git config user.name "CI User"
echo "# Local config advanced test" > README.md
git add README.md
git commit -m "init" &>/dev/null
git remote add origin https://example.com/fake.git

# Создаём локальный конфиг с disable_sync=false
cat <<EOF > .create-repo.local.conf
disable_sync=false
default_visibility=private
EOF

echo "🚀 Running create-repo..."
"$BIN" --platform=github --dry-run

# Проверяем наличие в списке
if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not tracked in ~/.repo-autosync.list"
  exit 1
fi

# Запускаем update-all c NO_PUSH, должно синхронизировать
UPDATE_LOG=$(mktemp)
NO_PUSH=true "$SCRIPT_DIR/update-all" >"$UPDATE_LOG" 2>&1 || {
  echo "❌ update-all failed"
  cat "$UPDATE_LOG"
  exit 1
}

if grep -q "skipped" "$UPDATE_LOG"; then
  echo "❌ Repo was unexpectedly skipped, but disable_sync=false"
  cat "$UPDATE_LOG"
  exit 1
fi

echo "ℹ️ Changing disable_sync to true..."
cat <<EOF > .create-repo.local.conf
disable_sync=true
EOF

NO_PUSH=true "$SCRIPT_DIR/update-all" >"$UPDATE_LOG" 2>&1 || {
  echo "❌ update-all failed"
  cat "$UPDATE_LOG"
  exit 1
}

if ! grep -q "skipped" "$UPDATE_LOG"; then
  echo "❌ Repo was not skipped, but disable_sync=true"
  cat "$UPDATE_LOG"
  exit 1
fi

echo "✅ Advanced local config test passed"
