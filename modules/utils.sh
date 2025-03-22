#!/bin/bash

# Проверка зависимостей
check_dependencies() {
  for cmd in git curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}❌ Missing dependency: $cmd${RESET}"
      exit 1
    fi
  done
}

# Подсказка похожего флага при опечатке
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
    local distance
    distance=$(levenshtein "$input" "$flag")
    if (( distance < min_distance )); then
      min_distance=$distance
      suggestion=$flag
    fi
  done

  if (( min_distance <= 3 )); then
    echo -e "${YELLOW}🤔 Did you mean: ${BOLD}$suggestion${RESET}${YELLOW}?${RESET}"
  fi
}

# Расчёт расстояния Левенштейна между двумя строками
levenshtein() {
  if [ "$1" = "$2" ]; then echo 0; return; fi
  local str1len=${#1}
  local str2len=${#2}
  local d i j
  for ((i=0; i<=str1len; i++)); do
    d[i,0]=$i
  done
  for ((j=0; j<=str2len; j++)); do
    d[0,$j]=$j
  done
  for ((i=1; i<=str1len; i++)); do
    for ((j=1; j<=str2len; j++)); do
      local cost=$(( ${1:i-1:1} != ${2:j-1:1} ))
      local del=$((d[i-1,j] + 1))
      local ins=$((d[i,j-1] + 1))
      local sub=$((d[i-1,j-1] + cost))
      d[i,j]=$(min "$del" "$ins" "$sub")
    done
  done
  echo "${d[str1len,str2len]}"
}

# Минимум из чисел
min() {
  local m=$1
  for n in "$@"; do
    (( n < m )) && m=$n
  done
  echo $m
}
# Получить URL для удаленного репозитория на основе платформы
get_remote_url() {
  local repo_name="$1"
  local platform="$2"

  case "$platform" in
    github)
      echo "https://github.com/your-username/$repo_name.git"
      ;;
    gitlab)
      echo "https://gitlab.com/your-username/$repo_name.git"
      ;;
    bitbucket)
      echo "https://bitbucket.org/your-username/$repo_name.git"
      ;;
    *)
      echo "https://example.com/$repo_name.git"
      ;;
  esac
}
