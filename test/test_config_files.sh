#!/bin/bash
set -e

echo "🧪 Testing config file generation..."

CONFIG="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

rm -f "$CONFIG" "$REPO_LIST"

"$CREATE_REPO_BIN" --version >/dev/null || {
  echo "❌ create-repo not working"
  exit 1
}

if [ ! -f "$CONFIG" ]; then
  echo "❌ Config file not created"
  exit 1
fi

if [ ! -f "$REPO_LIST" ]; then
  echo "❌ Repo list not created"
  exit 1
fi

echo "✅ Config test passed"
