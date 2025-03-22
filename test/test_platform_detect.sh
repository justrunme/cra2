#!/bin/bash
set -e

echo "🧪 Testing platform detection..."

BIN="${CREATE_REPO_BIN:-./create-repo}"  # fallback

OUTPUT=$("$BIN" --platform-status || true)

echo "📤 Output:"
echo "$OUTPUT"

if ! echo "$OUTPUT" | grep -qE 'GitHub|GitLab|Bitbucket'; then
  echo "❌ Platform not detected in output"
  exit 1
fi

echo "✅ Platform detection test passed"
