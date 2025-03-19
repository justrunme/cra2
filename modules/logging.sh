show_final_message() {
  local repo="$1"
  local branch="$2"
  local path="$3"
  local list="$4"
  local platform="$5"

  echo ""
  echo -e "${GREEN}🎉 Repo '$repo' initialized and pushed to $platform!${RESET}"
  echo "🌿 Branch: $branch"
  echo "📁 Path: $path"
  echo "📝 Tracked in: $list"
  echo "🔁 Auto-sync enabled (via update-all)"
  echo "ℹ️ Platform: $platform (configurable via --platform or .create-repo.local.conf)"
}
