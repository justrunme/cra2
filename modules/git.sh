#!/bin/bash
# git.sh — Git-related utilities for create-repo

# Show basic info about the current git repository
print_git_info() {
  if [ ! -d ".git" ]; then
    echo "🚫 This directory is not a Git repository."
    return 1
  fi

  echo "📘 Git Repository Info:"
  echo "🔀 Current branch:   $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  echo "🌐 Remote origin:    $(git remote get-url origin 2>/dev/null)"
  echo "🔄 Status summary:"
  git status -s || echo "⚠️ git status failed"
}

# Return the current git branch (fallback to main)
get_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"
}

# Return true if repository has uncommitted changes
has_uncommitted_changes() {
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    return 0  # yes
  else
    return 1  # clean
  fi
}

# Return true if current folder is a Git repository
is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Try to initialize git repo if not already a repo
try_git_init() {
  if ! is_git_repo; then
    echo "📦 Initializing new Git repository..."
    git init
    git add .
    git commit -m "Initial commit"
  fi
}
