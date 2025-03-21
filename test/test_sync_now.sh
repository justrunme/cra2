#!/bin/bash
echo "🧪 Testing --sync-now..."
tmpdir=$(mktemp -d)
cd "$tmpdir" || exit 1
git init >/dev/null
touch testfile.txt
git add . && git commit -m "init" >/dev/null
create-repo --sync-now >/dev/null
echo "✅ --sync-now test passed"
rm -rf "$tmpdir"
