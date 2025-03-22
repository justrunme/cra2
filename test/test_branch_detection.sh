#!/bin/bash
set -e

echo "🧪 Testing branch detection..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

"$BIN" --platform=github

if ! git rev-parse --abbrev-ref HEAD | grep -q "main"; then
  echo "❌ Branch not set to main"
  exit 1
fi

echo "✅ Branch detection test passed"
