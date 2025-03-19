#!/bin/bash

# Synchronization logic (used in update-all)

sync_repo() {
  local repo_path="$1"
  local now="$2"

  if [ ! -d "$repo_path/.git" ]; then
    log_error "$repo_path is not a git repository"
    return
  fi

  cd "$repo_path" || return
  echo -e "${YELLOW}🔄 Syncing: $repo_path${RESET}"

  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
  git add . &>/dev/null
  git commit -m "Auto-sync at $now" &>/dev/null || true
  git pull origin "$branch" --rebase &>/dev/null || true
  git push origin "$branch" &>/dev/null && log_success "$repo_path synced" || log_error "$repo_path push failed"
}
