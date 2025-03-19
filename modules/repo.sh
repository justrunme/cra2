#!/bin/bash

show_repo_status() {
  echo -e "${BLUE}📦 Git status for $(basename "$PWD")${RESET}"
  git status
}

show_log() {
  if [[ -f "$LOG_FILE" ]]; then
    echo -e "${BLUE}📜 Sync log:${RESET}"
    cat "$LOG_FILE"
  else
    echo -e "${YELLOW}⚠️ No log file found.${RESET}"
  fi
}

show_list() {
  if [[ -f "$REPO_LIST" ]]; then
    echo -e "${BLUE}📁 Tracked repos:${RESET}"
    cat "$REPO_LIST"
  else
    echo -e "${YELLOW}⚠️ No tracked repos.${RESET}"
  fi
}

perform_pull_only() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
  echo -e "${BLUE}🔄 Pulling latest changes from $branch...${RESET}"
  git pull origin "$branch"
}

perform_dry_run() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
  echo -e "${BLUE}🚀 Dry-run: git push origin $branch${RESET}"
  git push --dry-run origin "$branch"
}
