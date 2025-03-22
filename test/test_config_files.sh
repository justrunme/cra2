#!/bin/bash
# Скрипт для тестирования генерации конфигов
# Не используем set -e сразу, чтобы не вылетало на первой же ошибке
echo "🧪 Testing config file generation..."

set -x  # Показывает все команды перед выполнением

# Путь до бинарника (при CI он передаётся через CREATE_REPO_BIN)
BIN="${CREATE_REPO_BIN:-./create-repo}"

CONFIG="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

# Удалим старые файлы, если остались
rm -f "$CONFIG" "$REPO_LIST"

# Запускаем create-repo с аргументами (без интерактива)
"$BIN" my-test-repo \
  --platform=GitHub \
  --disable-sync \
  --no-push

RESULT=$?

# Вывод результата выполнения
if [ $RESULT -ne 0 ]; then
  echo "❌ create-repo exited with code $RESULT"
  exit 1
fi

# Проверяем наличие .conf
if [ ! -f "$CONFIG" ]; then
  echo "❌ Config file not created: $CONFIG"
  exit 1
fi

# Проверяем наличие списка репозиториев
if [ ! -f "$REPO_LIST" ]; then
  echo "❌ Repo list not created: $REPO_LIST"
  exit 1
fi

echo "✅ Config file test passed"
