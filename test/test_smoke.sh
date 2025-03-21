#!/bin/bash
set -e

echo "🧪 Running smoke test..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="$SCRIPT_DIR/../create-repo"

if [ ! -x "$REPO_PATH" ]; then
  echo "❌ create-repo not found or not executable at $REPO_PATH"
  exit 1
fi

VERSION_OUTPUT="$("$REPO_PATH" --version || true)"

if ! echo "$VERSION_OUTPUT" | grep -qE '^create-repo v[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "❌ version output not matched: $VERSION_OUTPUT"
  exit 1
fi

echo "✅ Smoke test passed"
