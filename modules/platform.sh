detect_platform() {
  local folder="$1"
  local override="$2"
  local is_dry_run="$3"

  echo "🔍 [platform.sh] folder=$folder" >&2
  echo "🔍 [platform.sh] override=$override" >&2
  echo "🔍 [platform.sh] is_dry_run=$is_dry_run" >&2

  # 1) override
  if [[ -n "$override" ]]; then
    echo "$folder=$override" >> "$PLATFORM_MAP"
    echo "$override"
    return
  fi

  # 2) check PLATFORM_MAP
  if [[ -f "$PLATFORM_MAP" ]]; then
    echo "🔍 [platform.sh] checking PLATFORM_MAP $PLATFORM_MAP" >&2
    local platform
    platform=$(grep "^$folder=" "$PLATFORM_MAP" | cut -d= -f2)
    if [[ -n "$platform" ]]; then
      echo "$platform"
      return
    fi
  fi

  # 3) parse remote url
  local remote
  remote=$(git -C "$folder" remote get-url origin 2>/dev/null || true)
  echo "🔍 [platform.sh] remote=$remote" >&2
  if [[ "$remote" == *"github.com"* ]]; then
    echo "$folder=github" >> "$PLATFORM_MAP"
    echo "github"
    return
  elif [[ "$remote" == *"gitlab.com"* ]]; then
    echo "$folder=gitlab" >> "$PLATFORM_MAP"
    echo "gitlab"
    return
  elif [[ "$remote" == *"bitbucket.org"* ]]; then
    echo "$folder=bitbucket" >> "$PLATFORM_MAP"
    echo "bitbucket"
    return
  fi

  # 4) fallback to installed CLI tokens
  platforms=()
  [[ -x "$(command -v gh)" ]] && gh auth status &>/dev/null && platforms+=("github")
  [[ -n "$GITLAB_TOKEN" ]] && platforms+=("gitlab")
  [[ -n "$BITBUCKET_USERNAME" && -n "$BITBUCKET_APP_PASSWORD" ]] && platforms+=("bitbucket")

  echo "🔍 [platform.sh] platforms found: ${platforms[*]}" >&2
  if [[ ${#platforms[@]} -eq 1 ]]; then
    # single platform
    echo "$folder=${platforms[0]}" >> "$PLATFORM_MAP"
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
