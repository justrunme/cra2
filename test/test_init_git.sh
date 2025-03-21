#!/bin/bash
echo "🧪 Testing git init..."
tmpdir=$(mktemp -d)
cd "$tmpdir" || exit 1
create-repo --interactive <<< $'my-test-repo\nn\n' >/dev/null
if [ ! -d .git ]; then
  echo "❌ Git repo not initialized"
  exit 1
fi
echo "✅ Git init test passed"
rm -rf "$tmpdir"
