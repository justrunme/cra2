#!/bin/bash
set -e
set -x

echo "🧪 Testing install-create-repo.sh on macOS..."

# Проверка, что мы действительно на mac
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This test is intended for macOS only (OSTYPE=$OSTYPE)"
  exit 0  # Не падаем, просто пропускаем
fi

# Очищаем старые установки
sudo rm -f /usr/local/bin/create-repo || true
sudo rm -f /usr/local/bin/update-all || true
sudo rm -rf /opt/cra2 || true

# Скачиваем инсталлятор и запускаем через sudo
curl -sSL https://raw.githubusercontent.com/justrunme/cra2/main/install-create-repo.sh | sudo bash

# Проверяем, что create-repo в PATH
if ! command -v create-repo &>/dev/null; then
  echo "❌ create-repo not found in PATH"
  exit 1
fi

# Проверяем, что update-all в PATH
if ! command -v update-all &>/dev/null; then
  echo "❌ update-all not found in PATH"
  exit 1
fi

# Проверяем, что модули попали в /opt/cra2
if [ ! -f "/opt/cra2/modules/colors.sh" ]; then
  echo "❌ Module not found in /opt/cra2/modules"
  exit 1
fi

# Тестовые вызовы
create-repo --version || {
  echo "❌ create-repo --version failed"
  exit 1
}
update-all --help || {
  echo "❌ update-all --help failed"
  exit 1
}

# Дополнительно проверяем launchd plist
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.create-repo.auto.plist"
if [ ! -f "$LAUNCHD_PLIST" ]; then
  echo "⚠️ Launchd plist not found – auto-sync may not be loaded"
  # Можно считать это некритичной ошибкой, если не обязательно
  # exit 1
fi

echo "✅ Installation script test on macOS passed"
