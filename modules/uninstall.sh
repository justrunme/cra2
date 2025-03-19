#!/bin/bash

# Uninstallation logic

uninstall_current_folder() {
  echo -e "${YELLOW}🧹 Uninstalling current folder from autosync...${RESET}"

  # Remove from tracked repos
  sed -i "\|$PWD|d" "$REPO_LIST" 2>/dev/null || true
  sed -i "\|$PWD=|d" "$PLATFORM_MAP" 2>/dev/null || true

  # Remove local config
  rm -f "$LOCAL_CONFIG_FILE"

  echo -e "${GREEN}✅ Uninstalled from autosync: $PWD${RESET}"
  exit 0
}
