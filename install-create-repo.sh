#!/bin/bash
set -e

INSTALL_BIN="/usr/local/bin"
INSTALL_DIR="/usr/local/lib/create-repo"
RAW_URL="https://raw.githubusercontent.com/justrunme/cra2/main"
NOW=$(date +"%Y-%m-%dT%H:%M:%S%z")

echo "📦 Installing create-repo..."
echo "⏱ Started at: $NOW"

if [ "$EUID" -ne 0 ]; then
  echo "❗ This script requires sudo. Try: sudo bash install-create-repo.sh"
  exit 1
fi

# Create target dir
mkdir -p "$INSTALL_DIR/modules"

# Download main script and modules
echo "⬇️  Downloading files..."
curl -fsSL "$RAW_URL/create-repo" -o "$INSTALL_DIR/create-repo"

for module in colors.sh flags.sh version.sh update.sh help.sh config.sh platform.sh repo.sh logger.sh; do
  curl -fsSL "$RAW_URL/modules/$module" -o "$INSTALL_DIR/modules/$module"
done

# Wrapper to /usr/local/bin/create-repo
echo "⚙️  Installing binary wrapper..."
cat > "$INSTALL_BIN/create-repo" <<EOF
#!/bin/bash
exec /usr/bin/env bash $INSTALL_DIR/create-repo "\$@"
EOF

chmod +x "$INSTALL_BIN/create-repo"

# Symlink as 'cra'
ln -sf "$INSTALL_BIN/create-repo" "$INSTALL_BIN/cra"

# Create config if missing
CONFIG_FILE="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

[ ! -f "$CONFIG_FILE" ] && cat <<EOF > "$CONFIG_FILE"
default_cron_interval=1
default_visibility=public
EOF

[ ! -f "$REPO_LIST" ] && touch "$REPO_LIST"

# Auto-sync setup
INTERVAL=$(grep default_cron_interval "$CONFIG_FILE" | cut -d= -f2)
INTERVAL=${INTERVAL:-1}

if [[ "$OSTYPE" == "darwin"* ]]; then
  plist="$HOME/Library/LaunchAgents/com.create-repo.auto.plist"
  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.create-repo.auto</string>
  <key>ProgramArguments</key>
  <array>
    <string>$INSTALL_BIN/update-all</string>
  </array>
  <key>StartInterval</key>
  <integer>$((INTERVAL * 60))</integer>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
  launchctl unload "$plist" &>/dev/null || true
  launchctl load "$plist"
else
  (crontab -l 2>/dev/null; echo "*/$INTERVAL * * * * $INSTALL_BIN/update-all # auto-sync") | sort -u | crontab -
fi

# Get latest version tag
VERSION=$(curl -s https://api.github.com/repos/justrunme/cra2/releases/latest | jq -r .tag_name)

echo ""
echo "✅ create-repo installed!"
echo "📂 create-repo path : $INSTALL_BIN/create-repo"
echo "📂 update-all path  : $INSTALL_BIN/update-all"
echo "📦 modules dir      : $INSTALL_DIR/modules"
echo "🧠 Try now          : create-repo --interactive"
echo "🔁 Auto-sync        : every $INTERVAL min"
echo "📝 Config file      : $CONFIG_FILE"
echo "📁 Repo list        : $REPO_LIST"
echo "🔖 Installed version: $VERSION"
