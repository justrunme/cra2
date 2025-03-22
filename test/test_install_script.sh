#!/bin/bash
set -e
set -x

echo "🧪 Testing install-create-repo.sh with sudo..."

# 1) Очищаем предыдущие установки (если были)
sudo rm -f /usr/local/bin/create-repo || true
sudo rm -f /usr/local/bin/update-all || true
sudo rm -rf /opt/cra2 || true

# 2) Скачиваем и устанавливаем скриптом
curl -sSL https://raw.githubusercontent.com/justrunme/cra2/main/install-create-repo.sh | sudo bash

# 3) Проверяем пути
echo "🔍 Checking /opt/cra2/modules existence..."
if [ ! -d "/opt/cra2/modules" ]; then
  echo "❌ Modules directory not found at /opt/cra2/modules"
  exit 1
fi

# 4) Проверяем бинарники
if ! command -v create-repo &>/dev/null; then
  echo "❌ create-repo not found in PATH after install"
  exit 1
fi
if ! command -v update-all &>/dev/null; then
  echo "❌ update-all not found in PATH after install"
  exit 1
fi

# 5) Тестовые вызовы
echo "🚀 create-repo --version"
create-repo --version || {
  echo "❌ create-repo --version failed"
  exit 1
}

echo "🚀 update-all --help"
update-all --help || {
  echo "❌ update-all --help failed"
  exit 1
}

echo "✅ Installation script test passed"
