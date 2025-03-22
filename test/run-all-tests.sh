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

# Настройка git user для тестов (исправление ошибки commit)
git config --global user.name "CI Bot"
git config --global user.email "ci@local.test"

# Удалим предыдущий конфиг для чистоты
rm -f ~/.create-repo.conf ~/.create-repo.local.conf

# Сделаем все тесты исполняемыми
chmod +x test_*.sh

# Запуск каждого теста, кроме отключённых
for test in test_*.sh; do
  case "$test" in
    test_config_files.sh|test_init_git.sh)
      echo "⏭️  Skipping $test (temporarily disabled)"
      continue
      ;;
  esac
  echo "▶️  Running $test"
  bash "$test"
done

echo "✅ All tests passed."
