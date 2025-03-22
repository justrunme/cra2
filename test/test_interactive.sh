#!/bin/bash
set -e

echo "🧪 Testing --interactive mode..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
echo "📁 TMP_DIR: $TMP_DIR"

# Пример ввода в интерактиве
INPUT=$(cat <<EOF
my-test-repo
n
EOF
)

echo "$INPUT" | "$BIN" --interactive --dry-run

if [ ! -d ".git" ]; then
  echo "❌ Git repo not created"
  exit 1
fi

echo "✅ Interactive mode test passed"
