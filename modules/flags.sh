#!/bin/bash

validate_flags() {
  VALID_FLAGS=(
    --help
    --interactive
    --platform=
    --platform-status
    --update
    --version
    --status
    --log
    --list
    --remove
    --clean
    --share
    --team
    --contributors
    --pull-only
    --dry-run
    --sync-now
  )

  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      base="${arg%%=*}"
      match=false
      for valid in "${VALID_FLAGS[@]}"; do
        [[ "$base" == "$valid" ]] && match=true && break
      done
      if ! $match; then
        echo -e "${RED}❌ Unknown flag: $arg${RESET}"
        echo -e "${YELLOW}➡️  Tip: run 'create-repo --help' to see available options${RESET}"
        exit 1
      fi
    elif [[ "$arg" == -* ]]; then
      echo -e "${RED}❌ Unknown short flag: $arg${RESET}"
      echo -e "${YELLOW}➡️  Tip: use long flags like --version or --help${RESET}"
      exit 1
    fi
  done
}
