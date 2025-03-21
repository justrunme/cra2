#!/bin/bash

# Устанавливаем лог-файлы, если не заданы
LOG_FILE="${LOG_FILE:-$HOME/.create-repo.log}"
ERROR_LOG="${ERROR_LOG:-$HOME/.create-repo-errors.log}"
MAX_LOG_SIZE=1048576  # 1 MB

rotate_logs() {
  local file="$1"
  if [[ -f "$file" && $(stat -c%s "$file") -gt $MAX_LOG_SIZE ]]; then
    mv "$file" "$file.1"
    echo "ℹ️  Log rotated: $file → $file.1"
  fi
}

log_success() {
  local name="$1"
  local path="$2"
  rotate_logs "$LOG_FILE"
  echo -e "${GREEN}✅ $name${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | SUCCESS | $name | $path" >> "$LOG_FILE"
}

log_error() {
  local name="$1"
  local path="$2"
  rotate_logs "$ERROR_LOG"
  echo -e "${RED}❌ $name${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | ERROR | $name | $path" >> "$ERROR_LOG"
}

log_info() {
  local message="$1"
  rotate_logs "$LOG_FILE"
  echo -e "${CYAN}ℹ️ $message${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | INFO | $message" >> "$LOG_FILE"
}
