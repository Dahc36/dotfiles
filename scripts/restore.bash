#!/usr/bin/env bash

set -euo pipefail

shopt -s nullglob dotglob

select_backup() {
  local backup="$(printf '%s\n' backup/*/ | fzf)"
  backup=${backup%/}
  echo "$backup"
}

backup=${1:-$(select_backup)}

restore_file() {
  local file="$1"
  local dest="$HOME${file#"$backup"}"
  rm "$dest"
  cp "$file" "$dest"
}

walk_backup() {
  local folder="$1"
  for file in "$folder"/*; do
    if [[ -d "$file" ]]; then
      walk_backup "$file"
    elif [[ -f "$file" ]]; then
      restore_file "$file"
    fi
  done
}

walk_backup "$backup"
