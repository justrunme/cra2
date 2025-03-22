#!/bin/bash

# Подключаем utils для suggest_flag
source "$SCRIPT_DIR/modules/utils.sh"

validate_flags() {
  # Обновлённый список валидных флагов:
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
    --force
    --clean
    --share
    --team
    --contributors
    --pull-only
    --dry-run
    --sync-now
    --doctor
    --only-tags=  # ← добавили сюда
  )

  echo "🧪 Validating flags: $*"

  for arg in "$@"; do
    echo "🔍 Checking flag: '$arg'"
    if [[ "$arg" == --* ]]; then
      base="${arg%%=*}"
      match=false
      for valid in "${VALID_FLAGS[@]}"; do
        echo "   ↪ Comparing to valid flag: '$valid'"
        # Проверяем:
        #   - exact match: $valid == $arg
        #   - match base + '=': (пример: base=--only-tags, $valid=--only-tags=)
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
