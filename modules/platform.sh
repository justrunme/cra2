detect_platform() {
  local folder="$1"
  local flag="$2"
  local map="$HOME/.create-repo.platforms"

  if [[ -n "$flag" ]]; then
    echo "$folder=$flag" >> "$map"
    echo "$flag"
    return
  fi

  if [[ -f "$map" ]]; then
    local saved=$(grep "^$folder=" "$map" | cut -d= -f2)
    [[ -n "$saved" ]] && echo "$saved" && return
  fi

  local available=()
  [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && available+=("github")
  [[ -n "$GITLAB_TOKEN" ]] && available+=("gitlab")
  [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && available+=("bitbucket")

  if [[ ${#available[@]} -eq 1 ]]; then
    echo "${available[0]}"
  elif [[ ${#available[@]} -gt 1 ]]; then
    echo -ne "${YELLOW}❓ Choose platform [github/gitlab/bitbucket]: ${RESET}"
    read chosen
    echo "$folder=$chosen" >> "$map"
    echo "$chosen"
  else
    echo ""
  fi
}
