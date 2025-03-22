#!/bin/bash

# Подключаем utils для suggest_flag
source "$SCRIPT_DIR/modules/utils.sh"

validate_flags() {
  VALID_FLAGS=(
    --help
    --interactive
    --platform
    --platform-status
    --update
    --upgrade
    --version
    --status
    --log
    --log=errors
    --list
    --remove
    --remove=--force
    --clean
    --share
    --team
    --contributors
    --pull-only
    --dry-run
    --sync-now
    --doctor
  )

  echo -e "${CYAN}🧪 DEBUG: Validating flags: ${BOLD}$*${RESET}"

  for arg in "$@"; do
    echo -e "${CYAN}🔍 Checking flag: '${BOLD}$arg${RESET}${CYAN}'${RESET}"
    
    if [[ "$arg" == --* ]]; then
      base="${arg%%=*}"
      match=false

      for valid in "${VALID_FLAGS[@]}"; do
        echo -e "   ↪ Comparing against: '${YELLOW}$valid${RESET}'"
        if [[ "$valid" == "$arg" || "$valid" == "$base" || "$valid" == "$base=" ]]; then
          match=true
          break
        fi
      done

      if ! $match; then
        echo -e "${RED}❌ Unknown flag: ${BOLD}$arg${RESET}"
        suggest_flag "$arg"
        echo -e "${YELLOW}➡️  Tip: run 'create-repo --help' to see available options${RESET}"
        exit 1
      fi

    elif [[ "$arg" == -* ]]; then
      echo -e "${RED}❌ Unknown short flag: ${BOLD}$arg${RESET}"
      suggest_flag "$arg"
      echo -e "${YELLOW}➡️  Tip: use long flags like --version or --help${RESET}"
      exit 1
    fi
  done
}
