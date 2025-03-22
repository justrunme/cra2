#!/bin/bash
set -e

echo "🧪 Testing platform detection via --platform-status..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

# Выполняем команду и сохраняем вывод
OUTPUT=$("$BIN" --platform-status 2>&1 || true)

echo "📤 Output:"
echo "$OUTPUT"

# Проверяем наличие известных платформ
if ! echo "$OUTPUT" | grep -qE 'GitHub|GitLab|Bitbucket'; then
  echo "❌ Platform not detected in output"
  exit 1
fi

echo "✅ Platform detection test passed"
