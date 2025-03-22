#!/bin/bash
set -e

echo "🧪 Testing local config override..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

echo "default_visibility=private" > .create-repo.local.conf

"$BIN" --platform=github

if ! grep -q "private" ~/.create-repo.log; then
  echo "❌ Local config override not applied"
  exit 1
fi

echo "✅ Local config override test passed"
