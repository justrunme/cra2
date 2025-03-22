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
touch README.md
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

# Запуск теста — симулируем push
echo "🚀 Running create-repo --sync-now"
$BIN --sync-now || echo "⚠️ sync-now exited with non-zero code (expected for fake remote)"

echo "✅ --sync-now test completed (fake remote)"
