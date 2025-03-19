#!/bin/bash

log_success() {
  echo -e "${GREEN}✔ $1${RESET}"
  echo "$NOW | SUCCESS | $1" >> "$LOG_FILE"
}

log_error() {
  echo -e "${RED}✖ $1${RESET}"
  echo "$NOW | ERROR | $1" >> "$ERROR_LOG"
}

