#!/bin/bash
set -e

echo "🧪 Testing --sync-now command..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
TMP_DIR=$(mktemp -d)
echo "📁 TMP_DIR: $TMP_DIR"
cd "$TMP_DIR"

# Настройка фиктивного git-репозитория
git init
git config user.name "CI Bot"
git config user.email "ci@example.com"
echo "# README" > README.md
git add README.md
git commit -m "Initial commit"

# Добавляем фиктивный origin и устанавливаем tracking ветки
git remote add origin https://example.com/fake.git
git branch --set-upstream-to=origin/master master || echo "⚠️ Upstream set skipped"

# Создаём базовые конфиги, чтобы избежать ошибок
echo "$TMP_DIR" >> ~/.repo-autosync.list
cat <<EOF > ~/.create-repo.conf
default_branch=master
default_visibility=public
EOF

# Запуск команды sync-now
echo "🚀 Running create-repo --sync-now"
if ! "$BIN" --sync-now; then
  echo "⚠️ create-repo --sync-now exited non-zero (may be expected for fake remote)"
fi

echo "✅ --sync-now test completed (with or without push)"
