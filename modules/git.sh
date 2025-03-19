#!/bin/bash

# Git-related functions

ensure_git_repo() {
  if [ ! -d .git ]; then
    git init &>/dev/null
  fi
}

checkout_branch() {
  local branch="$1"
  git checkout -b "$branch" &>/dev/null || git checkout "$branch"
}

initial_commit() {
  local now="$1"
  git add .
  git commit -m "Initial commit at $now" &>/dev/null || true
}

setup_remote() {
  local platform="$1"
  local repo="$2"
  local visibility="$3"
  local remote_url=""

  case "$platform" in
    github)
      local user=$(gh api user --jq .login)
      remote_url="git@github.com:$user/$repo.git"
      gh repo view "$repo" &>/dev/null || gh repo create "$repo" --$visibility --source=. --push
      ;;
    gitlab)
      local response=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --data "name=$repo&visibility=$visibility" https://gitlab.com/api/v4/projects)
      remote_url=$(echo "$response" | grep -oP '"ssh_url_to_repo":"\K[^"]+')
      ;;
    bitbucket)
      curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
        -X POST "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_USERNAME/$repo" \
        -H "Content-Type: application/json" \
        -d "{\"scm\": \"git\", \"is_private\": $( [[ "$visibility" == "private" ]] && echo true || echo false ) }"
      remote_url="git@bitbucket.org:$BITBUCKET_USERNAME/$repo.git"
      ;;
  esac

  git remote add origin "$remote_url" 2>/dev/null || true
  git push -u origin "$(git branch --show-current)" &>/dev/null || true
}
