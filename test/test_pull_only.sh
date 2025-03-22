#!/bin/bash
set -e

echo "🧪 Testing --pull-only..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null
git remote add origin https://example.com/fake.git
touch file.txt
git add file.txt
git config user.email "test@example.com"
git config user.name "Test User"
git commit -m "init" &>/dev/null

set +e
"$BIN" --pull-only
STATUS=$?
set -e

if [[ "$STATUS" -ne 0 ]]; then
  echo "✅ Expected pull failure"
else
  echo "❌ Pull unexpectedly succeeded"
  exit 1
fi
