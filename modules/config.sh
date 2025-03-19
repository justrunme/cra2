#!/bin/bash
CONFIG_FILE="$HOME/.create-repo.conf"
LOCAL_CONFIG_FILE=".create-repo.local.conf"
REPO_LIST="$HOME/.repo-autosync.list"
PLATFORM_MAP="$HOME/.create-repo.platforms"
LOG_FILE="$HOME/.create-repo.log"
ERROR_LOG="$HOME/.create-repo-errors.log"

load_config() {
  [[ -f "$LOCAL_CONFIG_FILE" ]] && source "$LOCAL_CONFIG_FILE"
  [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
}
