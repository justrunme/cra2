#!/bin/bash
set -e

echo "🧪 Running smoke test..."

BIN="${CREATE_REPO_BIN:-./create-repo}"

# Проверка на существование бинарника
if [[ ! -x "$BIN" ]]; then
  echo "❌ Binary not found or not executable: $BIN"
  exit 1
fi

# Получаем версию
output=$("$BIN" --version || true)

echo "📤 Output: $output"

# Проверяем, что версия подставлена корректно
if [[ "$output" == *"version:"* && "$output" != *"{{VERSION}}"* && "$output" != *"unknown"* ]]; then
  echo "✅ Smoke test passed"
else
  echo "❌ version output not matched or invalid: $output"
  exit 1
fi
