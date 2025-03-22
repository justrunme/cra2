#!/bin/bash
# status.sh — Display detailed sync and git status for current repo

print_repo_status() {
  echo "🔍 Repository Status"

  if [ ! -d ".git" ]; then
    echo "🚫 This directory is not a Git repository."
    return 1
  fi

  # Basic git info
  local branch origin remote_branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  origin=$(git remote get-url origin 2>/dev/null || echo "none")
  remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "no upstream")

  echo "📘 Branch:         $branch"
  echo "🌐 Remote origin:  $origin"
  echo "📤 Remote branch:  $remote_branch"

  # Git status
  echo "🔄 Changes:"
  git status -s || echo "⚠️ git status failed"

  # Try advanced fetch behind/ahead info
  if [ "$remote_branch" != "no upstream" ]; then
    echo "⚙️ Fetching to compare remote..."
    git fetch origin "$branch" &>/dev/null || echo "⚠️ fetch failed"

    # Count how many commits behind/ahead
    local behind ahead
    behind=$(git rev-list --count HEAD..origin/"$branch" 2>/dev/null || echo 0)
    ahead=$(git rev-list --count origin/"$branch"..HEAD 2>/dev/null || echo 0)
    echo "📊 Ahead:  $ahead commits"
    echo "📊 Behind: $behind commits"
  fi

  # Last push (if possible)
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

  # Check global config for cron interval
  if [ -f "$HOME/.create-repo.conf" ]; then
    local interval
    interval=$(grep "default_cron_interval=" "$HOME/.create-repo.conf" | cut -d= -f2)
    echo "⏱ Sync interval:  ${interval:-1} min"
  fi

  echo ""
}
