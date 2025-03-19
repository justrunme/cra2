#!/bin/bash

NOW=$(date "+%Y-%m-%d %H:%M:%S")
CURRENT_FOLDER=$(realpath "$PWD")
CONFIG_FILE="$HOME/.create-repo.conf"
LOCAL_CONFIG_FILE=".create-repo.local.conf"
PLATFORM_MAP="$HOME/.create-repo.platforms"
REPO_LIST="$HOME/.repo-autosync.list"
LOG_FILE="$HOME/.create-repo.log"
ERROR_LOG="$HOME/.create-repo-errors.log"
