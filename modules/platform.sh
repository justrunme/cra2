#!/bin/bash

detect_platform() {
  local folder="$1"
  local override="$2"
  local is_dry_run="$3"

  echo "🔍 [platform.sh] folder=$folder" >&2
  echo "🔍 [platform.sh] override=$override" >&2
  echo "🔍 [platform.sh] is_dry_run=$is_dry_run" >&2

  if [[ -n "$override" ]]; then
    echo "$folder=$override" >> "$PLATFORM_MAP"
    echo "$override"
    return
  fi

  if [[ -f "$PLATFORM_MAP" ]]; then
    echo "🔍 [platform.sh] checking PLATFORM_MAP $PLATFORM_MAP" >&2
    platform=$(grep "^$folder=" "$PLATFORM_MAP" | cut -d= -f2)
    [[ -n "$platform" ]] && echo "$platform" && return
  fi

  platforms=()
  [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && platforms+=("github")
  [[ -n "$GITLAB_TOKEN" ]] && platforms+=("gitlab")
  [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && platforms+=("bitbucket")

  echo "🔍 [platform.sh] platforms found: ${platforms[*]}" >&2

  if [[ ${#platforms[@]} -eq 1 ]]; then
    echo "${platforms[0]}"
  elif [[ ${#platforms[@]} -gt 1 ]]; then
    echo -ne "${YELLOW}❓ Choose platform [github/gitlab/bitbucket]: ${RESET}" >&2
    read chosen
    echo "$folder=$chosen" >> "$PLATFORM_MAP"
    echo "$chosen"
  else
    echo "⚠️ [platform.sh] No platforms detected. dry_run=$is_dry_run" >&2
    if [[ "$is_dry_run" == "true" ]]; then
      echo "unknown"
    else
      echo ""
    fi
  fi
}

show_platform_bindings() {
  echo "📦 Platform bindings:"
  echo "GitHub:    $(command -v gh >/dev/null && gh auth status &>/dev/null && echo '✅' || echo '❌')"
  echo "GitLab:    $(env | grep -q GITLAB_TOKEN && echo '✅' || echo '❌')"
  echo "Bitbucket: $([[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && echo '✅' || echo '❌')"
}
