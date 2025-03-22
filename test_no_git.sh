#!/bin/bash
set -e
set -x

echo "🧪 Testing environment with no valid git..."

# Переименуем git → git.real
sudo mv /usr/bin/git /usr/bin/git.real || {
  echo "❌ Cannot rename git"
  exit 0
}

# Создадим «фейк»
sudo bash -c 'echo "#!/bin/bash\necho \"git: command not found\"; exit 127" > /usr/bin/git'
sudo chmod +x /usr/bin/git

echo "🚀 Running create-repo..."
if create-repo --version; then
  echo "❌ Expected failure, but got success"
  exit 1
else
  echo "✅ create-repo failed as expected"
fi

# Восстанавливаем git
sudo rm /usr/bin/git
sudo mv /usr/bin/git.real /usr/bin/git

echo "✅ No-git test passed"
