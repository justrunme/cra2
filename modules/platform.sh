#!/bin/bash

detect_platform() {
  if [[ -n "$platform_flag" ]]; then
    platform="$platform_flag"
    echo "$CURRENT_FOLDER=$platform" >> "$PLATFORM_MAP"
  elif [[ -f "$PLATFORM_MAP" ]]; then
    platform=$(grep "^$CURRENT_FOLDER=" "$PLATFORM_MAP" | cut -d= -f2)
  fi

  if [[ -z "$platform" ]]; then
    available=()
    [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && available+=("github")
    [[ -n "$GITLAB_TOKEN" ]] && available+=("gitlab")
    [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && available+=("bitbucket")

    if [[ ${#available[@]} -eq 1 ]]; then
      platform="${available[0]}"
    elif [[ ${#available[@]} -gt 1 ]]; then
      echo -ne "${YELLOW}❓ Choose platform [github/gitlab/bitbucket]: ${RESET}"
      read chosen
      platform="$chosen"
      echo "$CURRENT_FOLDER=$platform" >> "$PLATFORM_MAP"
    fi
  fi

  if [[ -z "$platform" ]]; then
    echo -e "${RED}❌ No Git platform detected.${RESET}"
    exit 1
  fi
}
