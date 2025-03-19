#!/bin/bash
set -e

# 📦 Meta
RAW_URL="https://raw.githubusercontent.com/justrunme/cra2/main"
INSTALL_ROOT="/opt/cra2"
BIN_PATH="/usr/local/bin"
NOW=$(date +"%Y-%m-%dT%H:%M:%S")

echo "📦 Installing create-repo..."
echo "⏱ Started at: $NOW"

if [ "$EUID" -ne 0 ]; then
  echo "❗ This script requires sudo. Try: sudo bash install-create-repo.sh"
  exit 1
fi

# 🛠️ Create folders and fetch core scripts
mkdir -p "$INSTALL_ROOT/modules"
curl -fsSL "$RAW_URL/create-repo" -o "$INSTALL_ROOT/create-repo"
curl -fsSL "$RAW_URL/update-all" -o "$INSTALL_ROOT/update-all"
curl -fsSL "$RAW_URL/install-create-repo.sh" -o "$INSTALL_ROOT/install-create-repo.sh"
chmod +x "$INSTALL_ROOT/create-repo" "$INSTALL_ROOT/update-all" "$INSTALL_ROOT/install-create-repo.sh"

# ⬇️ Download all modules
modules=(colors.sh flags.sh version.sh update.sh help.sh config.sh platform.sh repo.sh logger.sh utils.sh cron.sh git.sh)
for mod in "${modules[@]}"; do
  echo "⬇️  Downloading module: $mod"
  curl -fsSL "$RAW_URL/modules/$mod" -o "$INSTALL_ROOT/modules/$mod"
done

# 🔗 Create symlinks
ln -sf "$INSTALL_ROOT/create-repo" "$BIN_PATH/create-repo"
ln -sf "$INSTALL_ROOT/create-repo" "$BIN_PATH/cra"
ln -sf "$INSTALL_ROOT/update-all" "$BIN_PATH/update-all"

# ✅ Rewrite internal source paths to absolute
sed -i 's|source "\$SCRIPT_DIR/modules/|source "/opt/cra2/modules/|g' "$INSTALL_ROOT/create-repo"
sed -i 's|source "\$SCRIPT_DIR/modules/|source "/opt/cra2/modules/|g' "$INSTALL_ROOT/update-all"

# ⚙️ Config files
CONFIG_FILE="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

[ ! -f "$CONFIG_FILE" ] && cat <<EOF > "$CONFIG_FILE"
default_cron_interval=1
default_visibility=public
EOF

[ ! -f "$REPO_LIST" ] && touch "$REPO_LIST"

# ⏱ Get sync interval
INTERVAL=$(grep default_cron_interval "$CONFIG_FILE" | cut -d= -f2)
INTERVAL=${INTERVAL:-1}

# ♻️ Setup auto-sync
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
    <string>$INSTALL_ROOT/update-all</string>
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
  (crontab -l 2>/dev/null; echo "*/$INTERVAL * * * * $INSTALL_ROOT/update-all # auto-sync") | sort -u | crontab -
fi

# ✅ Final message
echo ""
echo "✅ create-repo successfully installed!"
echo "📂 Installed to:  $INSTALL_ROOT"
echo "🔗 Commands:      create-repo (cra), update-all"
echo "🔁 Auto-sync:     every $INTERVAL min"
echo "⚙️  Config file:   $CONFIG_FILE"
echo "📝 Repo tracker:  $REPO_LIST"
