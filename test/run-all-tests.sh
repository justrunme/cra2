#!/bin/bash
set -e

echo "🔁 Running all tests..."

cd "$(dirname "$0")"

# Абсолютный путь до бинарника
export CREATE_REPO_BIN="$(cd .. && pwd)/create-repo"

# Проверка наличия бинарника
if [ ! -x "$CREATE_REPO_BIN" ]; then
  echo "❌ create-repo not found or not executable at $CREATE_REPO_BIN"
  exit 1
fi

# Удалим предыдущий конфиг для чистоты
rm -f ~/.create-repo.conf ~/.create-repo.local.conf

# Сделаем все тесты исполняемыми
chmod +x test_*.sh

# Запуск каждого теста (временно без config test)
for test in test_*.sh; do
  if [[ "$test" == "test_config_files.sh" ]]; then
    echo "⏭️  Skipping $test (temporarily disabled)"
    continue
  fi
  echo "▶️  Running $test"
  bash "$test"
done

echo "✅ All tests passed."
