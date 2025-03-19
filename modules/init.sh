#!/bin/bash

# Initialization and file preparation

prepare_files() {
  local repo="$1"
  [ ! -f README.md ] && echo "# $repo" > README.md
  [ ! -f .gitignore ] && echo ".DS_Store" > .gitignore
}
