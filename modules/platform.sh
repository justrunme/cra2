#!/bin/bash

detect_platform() {
  local folder="$1"
  local override="$2"
  local is_dry_run="$3"

  if [[ -n "$override" ]]; then
    echo "$folder=$override" >> "$PLATFORM_MAP"
    echo "$override"
    return
  fi

  if [[ -f "$PLATFORM_MAP" ]]; then
    platform=$(grep "^$folder=" "$PLATFORM_MAP" | cut -d= -f2)
    [[ -n "$platform" ]] && echo "$platform" && return
  fi

  platforms=()
  [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && platforms+=("github")
  [[ -n "$GITLAB_TOKEN" ]] && platforms+=("gitlab")
  [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && platforms+=("bitbucket")

  if [[ ${#platforms[@]} -eq 1 ]]; then
    echo "${platforms[0]}"
    return
  elif [[ ${#platforms[@]} -gt 1 ]]; then
    echo -ne "${YELLOW}❓ Choose platform [github/gitlab/bitbucket]: ${RESET}"
    read chosen
    echo "$folder=$chosen" >> "$PLATFORM_MAP"
    echo "$chosen"
    return
  fi

  # ❗ если ничего не найдено
  if [[ "$is_dry_run" == "true" ]]; then
    echo "github"  # ← возвращаем фиктивную платформу, чтобы dry-run прошёл
  else
    echo ""
  fi
}

show_platform_bindings() {
  echo "📦 Platform bindings:"
  echo "GitHub:    $(command -v gh >/dev/null && gh auth status &>/dev/null && echo '✅' || echo '❌')"
  echo "GitLab:    $(env | grep -q GITLAB_TOKEN && echo '✅' || echo '❌')"
  echo "Bitbucket: $([[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && echo '✅' || echo '❌')"
}
