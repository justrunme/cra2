#!/bin/bash

check_dependencies() {
  for cmd in git curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}❌ Missing dependency: $cmd${RESET}"
      exit 1
    fi
  done
}
