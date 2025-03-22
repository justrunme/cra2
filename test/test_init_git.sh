#!/bin/bash
set -e

echo "🧪 Testing git init..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TEST_DIR="$HOME/test-git-dir-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
echo "📁 TEST_DIR: $TEST_DIR"

"$BIN" --interactive <<EOF
my-test-repo
n
EOF

echo "📂 Contents of $TEST_DIR:"
ls -la

if [ ! -d .git ]; then
  echo "❌ Git repo not initialized"
  exit 1
fi

echo "✅ Git init test passed"
