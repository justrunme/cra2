#!/bin/bash

detect_platform() {
  local folder="$1"
  local override="$2"
  local is_dry_run="$3"

  echo "🔍 [platform.sh] folder=$folder"
  echo "🔍 [platform.sh] override=$override"
  echo "🔍 [platform.sh] is_dry_run=$is_dry_run"

  if [[ -n "$override" ]]; then
    echo "$folder=$override" >> "$PLATFORM_MAP"
    echo "$override"
    return
  fi

  if [[ -f "$PLATFORM_MAP" ]]; then
    echo "🔍 [platform.sh] checking PLATFORM_MAP $PLATFORM_MAP"
    platform=$(grep "^$folder=" "$PLATFORM_MAP" | cut -d= -f2)
    [[ -n "$platform" ]] && echo "$platform" && return
  fi

  platforms=()
  [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && platforms+=("github")
  [[ -n "$GITLAB_TOKEN" ]] && platforms+=("gitlab")
  [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && platforms+=("bitbucket")

  echo "🔍 [platform.sh] platforms found: ${platforms[*]}"

  if [[ ${#platforms[@]} -eq 1 ]]; then
    echo "${platforms[0]}"
  elif [[ ${#platforms[@]} -gt 1 ]]; then
    echo -ne "${YELLOW}❓ Choose platform [github/gitlab/bitbucket]: ${RESET}"
    read chosen
    echo "$folder=$chosen" >> "$PLATFORM_MAP"
    echo "$chosen"
  else
    echo "⚠️ [platform.sh] No platforms detected. dry_run=$is_dry_run"
    if [[ "$is_dry_run" == "true" ]]; then
      echo "unknown"
    else
      echo ""
    fi
  fi
}
