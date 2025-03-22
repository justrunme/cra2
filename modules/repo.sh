#!/bin/bash

print_repo_list() {
  local list_file="$HOME/.repo-autosync.list"
  [[ ! -s "$list_file" ]] && echo "No repositories found." && return

  echo -e "INDEX\tPLATFORM\tBRANCH\t\tPATH"
  echo "----------------------------------------------------------"

  local index=1
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local platform branch
    platform=$(detect_platform_from_config "$path")
    branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    printf "[%d]\t%s\t\t%s\t%s\n" "$index" "$platform" "$branch" "$path"
    ((index++))
  done < "$list_file"
}

detect_platform_from_config() {
  local remote=$(git -C "$1" remote get-url origin 2>/dev/null)
  [[ "$remote" == *github.com* ]] && echo "GitHub" && return
  [[ "$remote" == *gitlab.com* ]] && echo "GitLab" && return
  [[ "$remote" == *bitbucket.org* ]] && echo "Bitbucket" && return
  echo "Unknown"
}

print_status_all() {
  echo "🔍 Checking status of all tracked repositories..."
  while IFS= read -r path; do
    echo "===== $path ====="
    git -C "$path" status
    echo
  done < "$HOME/.repo-autosync.list"
}

remove_repo_force() {
  local target="$1"
  sed -i "\|$target|d" "$HOME/.repo-autosync.list"
  echo "$target removed from autosync list."
}

generate_readme() {
  if [[ ! -f README.md ]]; then
    echo "ℹ️ Generating README.md..."
    echo "# $(basename "$PWD")" > README.md
  fi
}

generate_gitignore() {
  if [[ ! -f .gitignore ]]; then
    echo "ℹ️ Generating .gitignore..."
    cat <<EOF > .gitignore
*.log
node_modules/
.env
dist/
__pycache__/
EOF
  fi
}

sync_now() {
  local repo_path
  repo_path="$(pwd)"

  echo "🔄 Syncing $repo_path"

  if ! git -C "$repo_path" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not a git repository."
    return 1
  fi

  git -C "$repo_path" pull --rebase || echo "⚠️ Pull failed."
  git -C "$repo_path" add .
  git -C "$repo_path" commit -m "Auto-sync $(date '+%F %T')" 2>/dev/null

  if [[ "$NO_PUSH" == "true" ]]; then
    echo "⚠️ Skipping git push due to NO_PUSH=true"
  else
    git -C "$repo_path" push || echo "Nothing to commit or push failed."
  fi
}

perform_pull_only() {
  local branch=$(git -C "$(pwd)" symbolic-ref --short HEAD 2>/dev/null || echo "main")
  echo -e "🔄 Pulling latest changes from $branch..."
  git -C "$(pwd)" pull origin "$branch"
}

perform_dry_run() {
  local branch=$(git -C "$(pwd)" symbolic-ref --short HEAD 2>/dev/null || echo "main")
  echo -e "🚀 Dry-run: git push origin $branch"
  echo "⚠️ Skipping git push (dry-run)"
}

git_init_repo() {
  local repo_name="$1"
  local branch="$2"
  local platform="$3"
  local visibility="$4"
  local timestamp="$5"
  local log_file="$6"
  local repo_list="$HOME/.repo-autosync.list"

  # Инициализация git, если нужно
  if [ ! -d ".git" ]; then
    git init -b "$branch"
  fi

  git add .
  git commit -m "Initial commit - $timestamp" >/dev/null 2>&1 || true

  # Добавляем origin, если не существует
  if ! git remote | grep -q origin; then
    remote_url=$(get_remote_url "$repo_name" "$platform")
    echo "🔗 Adding remote origin: $remote_url"
    git remote add origin "$remote_url"
  fi

  # Создаём файл списка, если его нет
  [[ ! -f "$repo_list" ]] && touch "$repo_list"

  # Добавляем текущий путь, если не был добавлен
  if ! grep -Fxq "$PWD" "$repo_list"; then
    echo "$PWD" >> "$repo_list"
  fi

  # Пушим, если не отключено переменной
  if [[ "$NO_PUSH" == "true" ]]; then
    echo "🚫 NO_PUSH=true → git push skipped"
  else
    echo "⬆️ Pushing to remote..."
    git push --set-upstream origin "$branch" || echo "⚠️ Push failed"
  fi

  log_info "Repo '$repo_name' initialized on '$platform' at $PWD" "$log_file"
}
