#!/bin/bash

# === Check required dependencies ===
check_dependencies() {
  for cmd in git curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}❌ Missing dependency: $cmd${RESET}"
      exit 1
    fi
  done
}

# === Suggest closest matching flag on typo ===
suggest_flag() {
  local input="$1"
  local -a known_flags=(
    "--interactive"
    "--platform"
    "--platform-status"
    "--sync-now"
    "--pull-before-sync"
    "--remove"
    "--update"
    "--upgrade"
    "--version"
    "--status"
    "--log"
    "--list"
    "--pull-only"
    "--dry-run"
    "--help"
  )

  local suggestion=""
  local min_distance=999

  for flag in "${known_flags[@]}"; do
    if [[ -n "$input" && -n "$flag" ]]; then
      local distance
      distance=$(levenshtein "$input" "$flag")
      if (( distance < min_distance )); then
        min_distance=$distance
        suggestion=$flag
      fi
    fi
  done

  if (( min_distance <= 3 )); then
    echo -e "${YELLOW}🤔 Did you mean: ${BOLD}$suggestion${RESET}${YELLOW}?${RESET}"
  fi
}

# === Levenshtein distance between two strings ===
levenshtein() {
  local s="$1"
  local t="$2"

  if [[ "$s" == "$t" ]]; then
    echo 0
    return
  fi

  local slen=${#s}
  local tlen=${#t}
  declare -A d
  local i j

  for (( i = 0; i <= slen; i++ )); do
    d[$i,0]=$i
  done
  for (( j = 0; j <= tlen; j++ )); do
    d[0,$j]=$j
  done

  for (( i = 1; i <= slen; i++ )); do
    for (( j = 1; j <= tlen; j++ )); do
      local char1="${s:i-1:1}"
      local char2="${t:j-1:1}"
      local cost=0
      if [[ "$char1" != "$char2" ]]; then
        cost=1
      fi
      local del=$(( d[i-1,j] + 1 ))
      local ins=$(( d[i,j-1] + 1 ))
      local sub=$(( d[i-1,j-1] + cost ))
      d[$i,$j]=$(min "$del" "$ins" "$sub")
    done
  done

  echo "${d[$slen,$tlen]}"
}

# === Return min from list of numbers ===
min() {
  local min_val=$1
  for val in "$@"; do
    if (( val < min_val )); then
      min_val=$val
    fi
  done
  echo "$min_val"
}
