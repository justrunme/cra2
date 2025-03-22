#!/bin/bash
set -e
set -x

echo "🧪 Testing installation script: install-create-repo.sh with sudo..."

# Очищаем возможные следы прошлой установки (требуется sudo)
sudo rm -f /usr/local/bin/create-repo || true
sudo rm -f /usr/local/bin/update-all || true
sudo rm -rf /opt/cra2 || true

# Скачиваем и устанавливаем, запускаем с sudo
curl -sSL https://raw.githubusercontent.com/justrunme/cra2/main/install-create-repo.sh | sudo bash

# Проверяем, что установилось
create-repo --version
update-all --help

echo "✅ Installation script test passed"
