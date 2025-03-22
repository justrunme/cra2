#!/bin/bash
set -e

echo "🧪 Testing --remove and --remove --force..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
git init -b main &>/dev/null

"$BIN" --platform=github

if ! grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not added"
  exit 1
fi

"$BIN" --remove || echo "⚠️ Expected non-forced remove without effect"

"$BIN" --remove --force

if grep -q "$TMP_DIR" ~/.repo-autosync.list; then
  echo "❌ Repo not removed"
  exit 1
fi

echo "✅ Remove test passed"
