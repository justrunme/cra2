#!/bin/bash
# status.sh — Display detailed sync and git status for current repo

print_repo_status() {
  echo "🔍 Repository Status"

  if [ ! -d ".git" ]; then
    echo "🚫 This directory is not a Git repository."
    return 1
  fi

  # Basic git info
  local branch origin remote
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  origin=$(git remote get-url origin 2>/dev/null || echo "none")
  remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no upstream")

  echo "📘 Branch:         $branch"
  echo "🌐 Remote origin:  $origin"
  echo "📤 Remote branch:  $remote_branch"

  # Git status
  echo "🔄 Changes:"
  git status -s || echo "⚠️ git status failed"

  # Last push (if possible)
  if git reflog show origin/"$branch" &>/dev/null; then
    last_push=$(git log origin/"$branch" -1 --format="%cd" --date=relative 2>/dev/null)
    echo "⏱ Last pushed:    $last_push"
  fi

  # Auto-sync tracking
  local list="$HOME/.repo-autosync.list"
  local path=$(pwd)
  if grep -Fxq "$path" "$list" 2>/dev/null; then
    echo "🟢 Auto-sync:      ENABLED ✅"
  else
    echo "🔴 Auto-sync:      DISABLED ❌"
  fi

  # Config
  if [ -f "$HOME/.create-repo.conf" ]; then
    local interval=$(grep "default_cron_interval=" "$HOME/.create-repo.conf" | cut -d= -f2)
    echo "⏱ Sync interval:  ${interval:-1} min"
  fi

  echo ""
}
