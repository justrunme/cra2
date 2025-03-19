#!/bin/bash

load_config() {
  if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
    source "$LOCAL_CONFIG_FILE"
  elif [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
  fi
}

save_config() {
  local file="$1"
  cat > "$file" <<EOF
default_visibility=${default_visibility:-public}
default_cron_interval=${default_cron_interval:-1}
default_team=${default_team}
default_branch=${default_branch:-main}
EOF
}
