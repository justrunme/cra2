#!/bin/bash
set -e

echo "🧪 Testing git init..."

BIN="${CREATE_REPO_BIN:-./create-repo}"  # fallback for local use

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
"$BIN" --interactive <<EOF
my-test-repo
n
EOF

if [ ! -d .git ]; then
  echo "❌ Git repo not initialized"
  exit 1
fi

echo "✅ Git init test passed"
