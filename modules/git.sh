#!/bin/bash
# git.sh — Git-related utilities for create-repo

# Print current git repository info (debug)
print_git_info() {
  echo "📘 Git Info Debug:"
  echo "🔍 PWD: $(pwd)"
  if [ ! -d ".git" ]; then
    echo "🚫 Not a Git repository."
    return 1
  fi

  echo "🔀 Branch:     $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  echo "🌐 Remote URL: $(git remote get-url origin 2>/dev/null || echo 'none')"
  echo "🔄 Status:"
  git status || echo "⚠️ git status failed"
  echo "🧼 Clean: $(has_uncommitted_changes && echo 'No' || echo 'Yes')"
}

# Return current branch name or fallback to "main"
get_current_branch() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
  echo "$branch"
}

# Detect uncommitted changes
has_uncommitted_changes() {
  [[ -n "$(git status --porcelain 2>/dev/null)" ]]
}

# Check if inside a Git repository
is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Try to initialize a git repo if none exists
try_git_init() {
  if ! is_git_repo; then
    echo "📦 Initializing Git repository..."
    git init -b main || { echo "❌ git init failed"; return 1; }
    git config user.name "CI User"
    git config user.email "ci@example.com"
    git add . || echo "⚠️ git add failed"
    git commit -m "Initial commit" || echo "⚠️ git commit failed (maybe nothing to commit)"
  else
    echo "✅ Already a Git repository."
  fi
}
