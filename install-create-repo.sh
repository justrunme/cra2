#!/bin/bash
set -e

INSTALL_BIN="/usr/local/bin"
INSTALL_LIB="/usr/local/lib/create-repo"
RAW_URL="https://raw.githubusercontent.com/justrunme/cra/main"
NOW=$(date +"%Y-%m-%dT%H:%M:%S%z")

echo "📦 Installing create-repo..."
echo "⏱ Started at: $NOW"

if [ "$EUID" -ne 0 ]; then
  echo "❗ This script requires sudo. Try: sudo bash install-create-repo.sh"
  exit 1
fi

# Create target folders
mkdir -p "$INSTALL_LIB"
mkdir -p "$INSTALL_BIN"

# Download core files
curl -fsSL "$RAW_URL/create-repo" -o "$INSTALL_LIB/create-repo"
curl -fsSL "$RAW_URL/update-all" -o "$INSTALL_LIB/update-all"
chmod +x "$INSTALL_LIB/create-repo" "$INSTALL_LIB/update-all"

# Download all modules
MODULES=(
  colors.sh
  config.sh
  flags.sh
  help.sh
  logger.sh
  platform.sh
  repo.sh
  update.sh
  utils.sh
  version.sh
)

mkdir -p "$INSTALL_LIB/modules"

for mod in "${MODULES[@]}"; do
  curl -fsSL "$RAW_URL/modules/$mod" -o "$INSTALL_LIB/modules/$mod"
done

# Create wrapper in /usr/local/bin
cat > "$INSTALL_BIN/create-repo" <<EOF
#!/bin/bash
exec /usr/local/lib/create-repo/create-repo "\$@"
EOF

chmod +x "$INSTALL_BIN/create-repo"

# Create shortcut
ln -sf "$INSTALL_BIN/create-repo" "$INSTALL_BIN/cra"

# Create user config files if missing
CONFIG_FILE="$HOME/.create-repo.conf"
REPO_LIST="$HOME/.repo-autosync.list"

[ ! -f "$CONFIG_FILE" ] && cat <<EOF > "$CONFIG_FILE"
default_cron_interval=1
default_visibility=public
EOF

[ ! -f "$REPO_LIST" ] && touch "$REPO_LIST"

INTERVAL=$(grep default_cron_interval "$CONFIG_FILE" | cut -d= -f2)
INTERVAL=${INTERVAL:-1}

# Setup auto-sync
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
    <string>$INSTALL_LIB/update-all</string>
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
  (crontab -l 2>/dev/null; echo "*/$INTERVAL * * * * $INSTALL_LIB/update-all # auto-sync") | sort -u | crontab -
fi

VERSION=$(curl -s https://api.github.com/repos/justrunme/cra/releases/latest | jq -r .tag_name)

echo ""
echo "✅ create-repo installed!"
echo "📂 Main:       $INSTALL_BIN/create-repo"
echo "📂 Lib path:   $INSTALL_LIB/"
echo "🔁 Auto-sync:  every $INTERVAL min"
echo "🧠 Try:        cra --interactive"
echo "🔖 Version:    $VERSION"
