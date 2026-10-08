#!/usr/bin/env bash

set -euo pipefail

shopt -s nullglob dotglob

if [[ ! -d "$PWD/backup" ]]; then
  echo "No backup/ in $PWD, run from the repo root" >&2
  exit 1
fi

report() {
  local outcome="$1"
  local path="$2"
  printf '%-9s %s\n' "$outcome" "$path"
}

select_backup() {
  if ! command -v fzf > /dev/null; then
    echo "fzf is required to choose a backup" >&2
    return 1
  fi

  local backups=("$PWD"/backup/*/)
  if (( ${#backups[@]} == 0 )); then
    echo "No backups in $PWD/backup" >&2
    return 1
  fi

  local backup
  backup=$(printf '%s\n' "${backups[@]}" | fzf) || return 1
  echo "$backup"
}

if (( $# > 0 )); then
  backup="$1"
else
  backup=$(select_backup) || exit 1
fi

backup=${backup%/}
if [[ -z "$backup" ]]; then
  echo "No backup selected" >&2
  exit 1
fi

restore_file() {
  local file="$1"
  local dest="$HOME${file#"$backup"}"
  if [[ -e "$dest" || -L "$dest" ]]; then
    rm "$dest"
  fi
  mkdir -p "${dest%/*}"
  cp "$file" "$dest"
  report restored "~${dest#"$HOME"}"
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
