#!/bin/bash

log_success() {
  local name="$1"
  local path="$2"
  echo -e "${GREEN}✅ $name${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | SUCCESS | $name | $path" >> "$LOG_FILE"
}

log_error() {
  local name="$1"
  local path="$2"
  echo -e "${RED}❌ $name${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | ERROR | $name | $path" >> "$ERROR_LOG"
}
