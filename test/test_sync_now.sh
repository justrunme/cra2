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
echo "# Test repo" > README.md
git add README.md
git commit -m "Initial commit"

# Добавим фиктивный origin
git remote add origin https://example.com/fake.git
git branch -M master
git branch --set-upstream-to=origin/master master || echo "⚠️ Upstream set skipped"

# Запишем путь в список трекаемых
echo "$TMP_DIR" >> ~/.repo-autosync.list

# Базовый конфиг
cat <<EOF > ~/.create-repo.conf
default_branch=master
default_visibility=public
EOF

# Привязка платформы
echo "$TMP_DIR=github" >> ~/.create-repo.platforms

# Запуск
echo "🚀 Running create-repo --sync-now"
NO_PUSH=true "$BIN" --sync-now

echo "✅ --sync-now test passed (NO_PUSH=true, no real push attempted)"
