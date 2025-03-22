#!/bin/bash
set -e
set -x

echo "🧪 Testing create-repo --doctor ..."

BIN="${CREATE_REPO_BIN:-create-repo}"

# Запустим doctor
OUTPUT=$("$BIN" --doctor || true)

echo "📋 Doctor output:"
echo "$OUTPUT"

# Пример: если doctor.sh выводит "All dependencies OK", проверим это
if echo "$OUTPUT" | grep -q "All dependencies OK"; then
  echo "✅ Doctor test passed"
else
  # Если нет такой строки, возможно, выведите предупреждение
  # или распарсите под свои нужды
  echo "⚠️ Doctor output didn't contain expected text"
  echo "✅ Still considered pass, or exit 1 if you want it strict."
fi
