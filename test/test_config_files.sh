#!/bin/bash
set -e

echo "🧪 Testing config file generation..."

BIN="${CREATE_REPO_BIN:-./create-repo}"  # fallback for local use

CONFIG="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

# Удалим старые файлы, если были
rm -f "$CONFIG" "$REPO_LIST"

# Принудительно создадим конфиг и список без push и sync
"$BIN" my-test-repo \
  --platform=GitHub \
  --disable-sync \
  --no-push

# Проверяем, созданы ли файлы
if [ ! -f "$CONFIG" ]; then
  echo "❌ Config file not created"
  exit 1
fi

if [ ! -f "$REPO_LIST" ]; then
  echo "❌ Repo list not created"
  exit 1
fi

echo "✅ Config file test passed"
