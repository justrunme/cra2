#!/bin/bash
# repo.sh — main repository-related functions for create-repo

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
  local remote
  remote=$(git -C "$1" remote get-url origin 2>/dev/null)
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

#
# sync_now():
# - optionally run .create-repo.pre-sync.sh
# - auto_rebase if set
# - commit changes if any
# - push unless NO_PUSH=true
# - optionally run .create-repo.post-sync.sh
#
sync_now() {
  local repo_path
  repo_path="$(pwd)"

  echo "🔄 Syncing $repo_path"

  # 1) Проверка, что это git
  if ! git -C "$repo_path" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "❌ Not a git repository."
    return 1
  fi

  # 2) pre-sync hook
  if [ -f ./.create-repo.pre-sync.sh ]; then
    echo "🔧 Running pre-sync hook..."
    if ! bash ./.create-repo.pre-sync.sh; then
      echo "❌ pre-sync hook failed. Aborting sync."
      return 1
    fi
  fi

  # 3) auto_rebase logic (если user хочет перебазирование)
  #    предполагаем, что load_config уже сделан (глобально)
  #    и у нас есть переменная auto_rebase
  if [[ "$auto_rebase" == "true" ]]; then
    echo "⬇️  git pull --rebase"
    if ! git -C "$repo_path" pull --rebase; then
      echo "⚠️ Pull/rebase failed or conflict"
      # можно return 1
    fi
  else
    echo "⬇️  git pull"
    if ! git -C "$repo_path" pull; then
      echo "⚠️ Pull failed."
      # можно return 1
    fi
  fi

  # 4) commit
  git -C "$repo_path" add .
  if ! git -C "$repo_path" commit -m "Auto-sync $(date '+%F %T')" 2>/dev/null; then
    echo "nothing to commit, working tree clean"
    # не считаем это ошибкой
  fi

  # 5) push
  if [[ "$NO_PUSH" == "true" ]]; then
    echo "⚠️ Skipping git push due to NO_PUSH=true"
  else
    echo "⬆️  git push"
    # не выходим с кодом 1, если пуш упал, просто сообщаем
    if ! git -C "$repo_path" push; then
      echo "⚠️ Push failed (no changes or remote error?)"
    fi
  fi

  # 6) post-sync hook
  if [ -f ./.create-repo.post-sync.sh ]; then
    echo "🔧 Running post-sync hook..."
    if ! bash ./.create-repo.post-sync.sh; then
      echo "⚠️ post-sync hook failed (continuing anyway)"
      # не падаем
    fi
  fi

  return 0
}

perform_pull_only() {
  local branch
  branch=$(git -C "$(pwd)" symbolic-ref --short HEAD 2>/dev/null || echo "main")
  echo -e "🔄 Pulling latest changes from $branch..."
  git -C "$(pwd)" pull origin "$branch"
}

perform_dry_run() {
  local branch
  branch=$(git -C "$(pwd)" symbolic-ref --short HEAD 2>/dev/null || echo "main")
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
    if command -v get_remote_url >/dev/null 2>&1; then
      remote_url=$(get_remote_url "$repo_name" "$platform")
    else
      echo "⚠️ Function get_remote_url not found. Using fallback URL."
      remote_url="https://example.com/$repo_name.git"
    fi
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
