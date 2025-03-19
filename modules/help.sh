#!/bin/bash
show_help() {
  echo -e "${BLUE}📦 create-repo — DevOps automation CLI${RESET}"
  echo "Usage: create-repo [repo-name] [--platform=github|gitlab|bitbucket] [--interactive]"
  echo "Flags: --update, --version, --help, --platform-status, --platform=PLATFORM"
}
