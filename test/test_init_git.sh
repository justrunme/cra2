#!/bin/bash
set -e

echo "🧪 Testing git init..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TEST_DIR="$HOME/test-git-dir-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
echo "📁 TEST_DIR: $TEST_DIR"
echo "📂 Contents before: $(ls -la)"

echo "🚀 Running create-repo with --interactive"
OUTPUT_FILE="$TEST_DIR/output.log"

"$BIN" --interactive <<EOF >"$OUTPUT_FILE" 2>&1
my-test-repo
n
EOF

RC=$?
echo "🔧 Exit code: $RC"
echo "📜 Output:"
cat "$OUTPUT_FILE" || echo "⚠️ No output captured"

echo "📂 Contents after:"
ls -la

if [ ! -d .git ]; then
  echo "❌ Git repo not initialized"
  exit 1
fi

echo "✅ Git init test passed"
