#!/bin/bash
# cron.sh — Cross-platform cron/launchd support for auto-sync

CONFIG_FILE="$HOME/.create-repo.conf"
CRON_COMMENT="# auto-sync"
LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.create-repo.auto.plist"

# Extract interval (in minutes) from config or default to 5
get_cron_interval() {
  grep -E "^default_cron_interval=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]' || echo "5"
}

# Setup cron job for Linux
setup_cron_linux() {
  local interval
  interval=$(get_cron_interval)
  local cronjob="*/$interval * * * * /usr/local/bin/update-all $CRON_COMMENT"

  # Remove old job if exists, then add new
  (crontab -l 2>/dev/null | grep -v "$CRON_COMMENT"; echo "$cronjob") | crontab -
  echo "🕒 Cron job installed: every $interval min"
}

# Setup launchctl job for macOS
setup_cron_macos() {
  local interval
  interval=$(get_cron_interval)
  mkdir -p "$(dirname "$LAUNCHD_PLIST")"

  cat > "$LAUNCHD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.create-repo.auto</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/update-all</string>
  </array>
  <key>StartInterval</key>
  <integer>$((interval * 60))</integer>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF

  launchctl unload "$LAUNCHD_PLIST" &>/dev/null || true
  launchctl load "$LAUNCHD_PLIST"
  echo "🕒 LaunchAgent installed: every $interval min"
}

# Platform-aware installer
setup_cron_job() {
  case "$OSTYPE" in
    linux*)  setup_cron_linux ;;
    darwin*) setup_cron_macos ;;
    *) echo "❌ Unsupported OS for cron setup: $OSTYPE" ;;
  esac
}

# Show current sync config status
print_cron_status() {
  local interval
  interval=$(get_cron_interval)

  echo "🔁 Auto-sync interval: every $interval minute(s)"
  case "$OSTYPE" in
    linux*)
      echo "🔍 Crontab entry:"
      crontab -l 2>/dev/null | grep "$CRON_COMMENT" || echo "⚠️  No auto-sync job found"
      ;;
    darwin*)
      echo "🔍 LaunchAgent:"
      if [ -f "$LAUNCHD_PLIST" ]; then
        grep -A1 "<key>StartInterval</key>" "$LAUNCHD_PLIST" || echo "⚠️  Interval not found"
      else
        echo "⚠️  No launchd job found"
      fi
      ;;
    *)
      echo "⚠️  Unsupported OS: $OSTYPE"
      ;;
  esac
}
