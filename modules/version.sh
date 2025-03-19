#!/bin/bash

# Version handling

print_version() {
  echo -e "${GREEN}create-repo version: ${SCRIPT_VERSION}${RESET}"
}

check_for_updates() {
  echo -e "${BLUE}⬆️ Checking for update...${RESET}"
  latest_version=$(curl -s https://api.github.com/repos/justrunme/cra/releases/latest | jq -r .tag_name)

  if [[ "$latest_version" != "$SCRIPT_VERSION" ]]; then
    echo -e "${YELLOW}🆕 New version available: $latest_version (current: $SCRIPT_VERSION)${RESET}"
    tmpdir=$(mktemp -d)
    curl -fsSL https://raw.githubusercontent.com/justrunme/cra/main/create-repo -o "$tmpdir/create-repo"
    curl -fsSL https://raw.githubusercontent.com/justrunme/cra/main/update-all -o "$tmpdir/update-all"
    sudo cp "$tmpdir/create-repo" /usr/local/bin/create-repo
    sudo cp "$tmpdir/update-all" /usr/local/bin/update-all
    sudo chmod +x /usr/local/bin/create-repo /usr/local/bin/update-all
    echo -e "${GREEN}✅ Updated to $latest_version${RESET}"
  else
    echo -e "${GREEN}✅ Already up to date: $SCRIPT_VERSION${RESET}"
  fi

  exit 0
}
