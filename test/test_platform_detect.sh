#!/bin/bash
echo "🧪 Testing platform detection..."
touch ~/.create-repo.conf
echo "default_platform=GitHub" >> ~/.create-repo.conf
create-repo --platform-status | grep -q "GitHub" || {
  echo "❌ Platform not detected"
  exit 1
}
echo "✅ Platform detection passed"
