doctor_check() {
  echo "== CRA2 Doctor =="

  for cmd in git curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Missing: $cmd"
    else
      echo "OK: $cmd"
    fi
  done

  [[ ! -f "$HOME/.repo-autosync.list" ]] && echo "No .repo-autosync.list found"
  [[ ! -f "$HOME/.create-repo.conf" ]] && echo "No global config found"
  [[ ! -s "$HOME/.create-repo.log" ]] && echo "No logs yet"
  [[ -n "$GITLAB_TOKEN" ]] && echo "GitLab token: OK"
  [[ -n "$GITHUB_TOKEN" ]] && echo "GitHub token: OK"

  echo "Doctor check complete."
}
