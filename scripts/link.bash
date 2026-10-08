#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# walk_src's glob needs both: dotglob to match dotfiles, nullglob for empty folders
shopt -s nullglob
shopt -s dotglob

src_abs_path="$PWD/src"

if [[ ! -d "$src_abs_path" ]]; then
  echo "No src/ in $PWD, run from the repo root" >&2
  exit 1
fi

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
fi

timestamp=${TIMESTAMP:-$(date +%Y_%m_%d-%H_%M_%S)}
backup_path="$PWD/backup/$timestamp"


report() {
  local outcome="$1"
  local path="$2"
  printf '%-9s %s\n' "$outcome" "$path"
}

link_dest() {
  local src="$1"
  local dest="$2"
  if [[ "$dry_run" == true ]]; then
    return
  fi
  mkdir -p "${dest%/*}"
  ln -s "$src" "$dest"
}

backup_dest() {
  local dest="$1"
  local backup_full_path="$backup_path${dest#"$HOME"}"
  if [[ "$dry_run" == true ]]; then
    return
  fi
  mkdir -p "${backup_full_path%/*}"
  mv "$dest" "$backup_full_path"
}

remove_dest() {
  local dest="$1"
  if [[ "$dry_run" == true ]]; then
    return
  fi
  rm "$dest"
}

sync_src() {
  local src="$1"
  local dest="$HOME${src#"$src_abs_path"}"
  local home_path="~${dest#"$HOME"}"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      report ok "$home_path"
      return
    fi

    local outcome=repaired
    if [[ -e "$dest" ]]; then
      outcome=relinked
    fi

    backup_dest "$dest"
    link_dest "$src" "$dest"
    report "$outcome" "$home_path"
    return
  fi

  if [[ ! -e "$dest" ]]; then
    link_dest "$src" "$dest"
    report linked "$home_path"
    return
  fi

  if [[ -d "$dest" ]]; then
    report skipped "$home_path"
    return
  fi

  if cmp -s "$src" "$dest"; then
    remove_dest "$dest"
    link_dest "$src" "$dest"
    report replaced "$home_path"
    return
  fi

  backup_dest "$dest"
  link_dest "$src" "$dest"
  report backed-up "$home_path"
}

walk_src() {
  local folder="$1"
  for file in "$folder"/*; do
    if [[ "${file##*/}" == ".DS_Store" ]]; then
      report ignored "${file#"$PWD"/}"
    elif [[ -L "$file" ]]; then
      continue
    elif [[ -d "$file" ]]; then
      walk_src "$file"
    elif [[ -f "$file" ]]; then
      sync_src "$file"
    fi
  done
}

walk_src "$src_abs_path"
