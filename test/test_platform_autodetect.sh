#!/bin/bash
set -e
set -x

echo "🧪 Testing platform auto-detect..."

BIN="${CREATE_REPO_BIN:-./create-repo}"
TMP_DIR=$(mktemp -d)
echo "📁 TMP_DIR: $TMP_DIR"
cd "$TMP_DIR"

git init -b main &>/dev/null
git config user.email "ci@example.com"
git config user.name "CI User"
echo "# Test autodetect" > README.md
git add README.md
git commit -m "init" &>/dev/null

# === Case A: GitHub
git remote add origin git@github.com:username/autodetect.git

NO_PUSH=true "$BIN" --dry-run || {
  echo "❌ create-repo failed"
  exit 1
}

# Проверим ~/.create-repo.platforms
if ! grep -q "github" ~/.create-repo.platforms; then
  echo "❌ GitHub not detected in platform map"
  exit 1
fi
echo "✅ GitHub auto-detect works"

# Очистим
sed -i "/$TMP_DIR/d" ~/.repo-autosync.list
rm -f ~/.create-repo.platforms

# === Case B: GitLab
git remote remove origin
git remote add origin git@gitlab.com:username/autodetect.git

NO_PUSH=true "$BIN" --dry-run || {
  echo "❌ create-repo failed"
  exit 1
}

if ! grep -q "gitlab" ~/.create-repo.platforms; then
  echo "❌ GitLab not detected in platform map"
  exit 1
fi
echo "✅ GitLab auto-detect works"

# Очистим
sed -i "/$TMP_DIR/d" ~/.repo-autosync.list
rm -f ~/.create-repo.platforms

# === Case C: Bitbucket
git remote remove origin
git remote add origin git@bitbucket.org:username/autodetect.git

NO_PUSH=true "$BIN" --dry-run || {
  echo "❌ create-repo failed"
  exit 1
}

if ! grep -q "bitbucket" ~/.create-repo.platforms; then
  echo "❌ Bitbucket not detected in platform map"
  exit 1
fi
echo "✅ Bitbucket auto-detect works"

echo "✅ Platform auto-detect test passed"
