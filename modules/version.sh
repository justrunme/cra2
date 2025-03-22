#!/bin/bash

# Если подставлено при сборке — используем подставленную версию
SCRIPT_VERSION="{{VERSION}}"

# Если всё ещё плейсхолдер — пробуем получить версию из git (для локальной разработки)
if [[ "$SCRIPT_VERSION" == "{{VERSION}}" ]]; then
  SCRIPT_VERSION=$(git describe --tags --always 2>/dev/null || echo "unknown")
fi

show_version() {
  echo -e "${GREEN}create-repo version: ${SCRIPT_VERSION}${RESET}"
}
