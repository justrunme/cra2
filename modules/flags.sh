VALID_FLAGS=(--help --interactive --platform= --platform-status --update --version --status --log --list --remove --clean --share --team --contributors --pull-only --dry-run --sync-now)

validate_flags() {
  for arg in "$@"; do
    if [[ "$arg" == --* ]]; then
      base_flag="${arg%%=*}"
      match_found=false
      for valid in "${VALID_FLAGS[@]}"; do
        [[ "$valid" == "$base_flag" ]] && match_found=true && break
      done
      if ! $match_found; then
        echo -e "${RED}❌ Unknown flag: $arg${RESET}"
        echo -e "${YELLOW}➡️  Tip: run 'create-repo --help' to see available options${RESET}"
        exit 1
      fi
    elif [[ "$arg" == -* ]]; then
      echo -e "${RED}❌ Unknown short flag: $arg${RESET}"
      echo -e "${YELLOW}➡️  Tip: run 'create-repo --help' to see available options${RESET}"
      exit 1
    fi
  done
}
