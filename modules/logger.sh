#!/bin/bash
log_success() {
  echo -e "${GREEN}✅ $1${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | SUCCESS | $1" >> "$LOG_FILE"
}
log_error() {
  echo -e "${RED}❌ $1${RESET}"
  echo "$(date "+%Y-%m-%d %H:%M:%S") | ERROR | $1" >> "$ERROR_LOG"
}
