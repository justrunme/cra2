#!/bin/bash
set -e

echo "🧪 Testing --pull-only..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null
git config user.email "test@example.com"
git config user.name "Test User"
touch file.txt
git add file.txt
git commit -m "init" &>/dev/null
git remote add origin https://example.com/fake.git

# Добавим в трекаемые, чтобы симулировать поведение
echo "$TMP_DIR" >> ~/.repo-autosync.list

# Выполняем pull-only
set +e
"$BIN" --pull-only
STATUS=$?
set -e

if [[ "$STATUS" -ne 0 ]]; then
  echo "✅ Expected pull failure due to fake remote"
else
  echo "❌ Pull unexpectedly succeeded"
  exit 1
fi
