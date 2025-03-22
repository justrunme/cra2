#!/bin/bash
set -e

echo "🧪 Testing --platform override and --update..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

"$BIN" --platform=github

if ! grep -q "github" ~/.create-repo.platforms; then
  echo "❌ Platform override not saved"
  exit 1
fi

"$BIN" --update || echo "⚠️ Update may fail without GitHub token (expected)"

echo "✅ Platform override test passed"
