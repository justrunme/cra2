git_init_repo() {
  local repo_name="$1"
  local branch="$2"
  local platform="$3"
  local visibility="$4"
  local now="$5"
  local log_file="$6"
  local repo_list="$7"

  git init &>/dev/null
  git checkout -b "$branch" &>/dev/null || git checkout "$branch"

  [ ! -f README.md ] && echo "# $repo_name" > README.md
  [ ! -f .gitignore ] && echo ".DS_Store" > .gitignore

  git add .
  git commit -m "Initial commit at $now" &>/dev/null || true

  if [[ "$platform" == "github" ]]; then
    user=$(gh api user --jq .login)
    remote_url="git@github.com:$user/$repo_name.git"
    if ! gh repo view "$repo_name" &>/dev/null; then
      echo -ne "${YELLOW}⚠️ Repo already exists. Overwrite remote? [pull to sync / ENTER to overwrite]: ${RESET}"
      read choice
      if [[ "$choice" == "pull" ]]; then
        git pull origin "$branch" --no-edit || true
      else
        gh repo create "$repo_name" --$visibility --source=. --push
      fi
    fi
  elif [[ "$platform" == "gitlab" ]]; then
    response=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      --data "name=$repo_name&visibility=$visibility" https://gitlab.com/api/v4/projects)
    remote_url=$(echo "$response" | grep -oP '"ssh_url_to_repo":"\K[^"]+')
  elif [[ "$platform" == "bitbucket" ]]; then
    curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
      -X POST "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_USERNAME/$repo_name" \
      -H "Content-Type: application/json" \
      -d "{\"scm\": \"git\", \"is_private\": $( [[ "$visibility" == "private" ]] && echo true || echo false ) }"
    remote_url="git@bitbucket.org:$BITBUCKET_USERNAME/$repo_name.git"
  fi

  git remote add origin "$remote_url" 2>/dev/null || true
  git push -u origin "$branch" &>/dev/null || true

  grep -qxF "$PWD" "$repo_list" || echo "$PWD" >> "$repo_list"
  echo "$now | $PWD | synced to $platform on branch $branch" >> "$log_file"
}
