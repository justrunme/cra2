#!/bin/bash
echo "🧪 Testing config file generation..."
rm -f ~/.create-repo.conf
create-repo --help >/dev/null
if [ ! -f ~/.create-repo.conf ]; then
  echo "❌ Config file not created"
  exit 1
fi
echo "✅ Config file test passed"
