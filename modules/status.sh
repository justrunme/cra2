#!/bin/bash
# status.sh — Display detailed sync and git status for current repo
# Usage: source status.sh && print_repo_status
# This script shows:
#   - Current branch, remote URL and upstream branch.
#   - Short git status (staged/unstaged changes).
#   - Advanced info: number of commits ahead/behind remote.
#   - Date of last push (if available).
#   - Whether auto-sync is enabled and the configured sync interval.

print_repo_status() {
  echo "🔍 Repository Status"

  if [ ! -d ".git" ]; then
    echo "🚫 This directory is not a Git repository."
    return 1
  fi

  # Basic Git info
  local branch origin remote_branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  origin=$(git remote get-url origin 2>/dev/null || echo "none")
  remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "no upstream")

  echo "📘 Branch:         $branch"
  echo "🌐 Remote origin:  $origin"
  echo "📤 Remote branch:  $remote_branch"

  # Git status (short)
  echo "🔄 Changes:"
  git status -s || echo "⚠️ git status failed"

  # Advanced: Fetch and count commits ahead/behind remote (если upstream настроен)
  if [ "$remote_branch" != "no upstream" ]; then
    echo "⚙️ Fetching to compare with remote..."
    if ! git fetch origin "$branch" &>/dev/null; then
      echo "⚠️ fetch failed"
    fi

    local behind ahead
    behind=$(git rev-list --count HEAD..origin/"$branch" 2>/dev/null || echo 0)
    ahead=$(git rev-list --count origin/"$branch"..HEAD 2>/dev/null || echo 0)
    echo "📊 Ahead:  $ahead commits"
    echo "📊 Behind: $behind commits"
  fi

  # Last push info, если доступно
  if git rev-parse "origin/$branch" &>/dev/null; then
    local last_push
    last_push=$(git log origin/"$branch" -1 --format="%cd" --date=relative 2>/dev/null)
    echo "⏱ Last pushed:    $last_push"
  fi

  # Auto-sync tracking
  local list="$HOME/.repo-autosync.list"
  local path
  path=$(pwd)
  if [ -f "$list" ] && grep -Fxq "$path" "$list" 2>/dev/null; then
    echo "🟢 Auto-sync:      ENABLED ✅"
  else
    echo "🔴 Auto-sync:      DISABLED ❌"
  fi

  # Global config: Sync interval (cron)
  if [ -f "$HOME/.create-repo.conf" ]; then
    local interval
    interval=$(grep "default_cron_interval=" "$HOME/.create-repo.conf" | cut -d= -f2)
    echo "⏱ Sync interval:  ${interval:-1} min"
  fi

  echo ""
}

# Если требуется, можно добавить функцию для проверки статуса всех репозиториев:
print_advanced_status_all() {
  echo "🔍 Advanced Status for All Tracked Repos:"
  while IFS= read -r path || [[ -n "$path" ]]; do
    [ -z "$path" ] && continue
    echo "===== Repository: $path ====="
    (cd "$path" && print_repo_status)
    echo ""
  done < "$HOME/.repo-autosync.list"
}
