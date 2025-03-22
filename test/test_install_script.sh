#!/bin/bash
set -e
set -x

echo "🧪 Testing installation script: install-create-repo.sh"

# Очищаем потенциальные следы предыдущих установок
sudo rm -f /usr/local/bin/create-repo || true
sudo rm -f /usr/local/bin/update-all || true
sudo rm -rf /opt/cra2 || true

# Скачиваем и запускаем
curl -sSL https://raw.githubusercontent.com/justrunme/cra2/main/install-create-repo.sh | bash

# Проверяем, что скрипты появились
if ! command -v create-repo &>/dev/null; then
  echo "❌ create-repo not found in PATH after install"
  exit 1
fi

if ! command -v update-all &>/dev/null; then
  echo "❌ update-all not found in PATH after install"
  exit 1
fi

# Проверяем корректную работу
create-repo --version
update-all --help

echo "✅ Installation script test passed"
