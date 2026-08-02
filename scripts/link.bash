#!/usr/bin/env bash

set -e
set -u
set -o pipefail

shopt -s nullglob
shopt -s dotglob

src_abs_path="$PWD/src"
backup_path="$PWD/backup/$(date +%Y_%m_%d-%H_%M_%S)"


link_file() {
  local src="$1"
  local dest="$2"
  echo "Linking: $dest -> $src"
  ln -s "$src" "$dest"
}

sync_file() {
  local src="$1"
  local dest="$HOME${src#"$src_abs_path"}"
  local backup_full_path="$backup_path${src#"$src_abs_path"}"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "Already linked: $dest"
    return
  fi

  if [[ -L "$dest" ]]; then
    echo "Removing link: $dest -> $(readlink "$dest")"
    rm "$dest"
    link_file "$src" "$dest"
    return
  fi

  if [[ ! -e "$dest" ]]; then
    mkdir -p "${dest%/*}"
    link_file "$src" "$dest"
    return
  fi

  if cmp -s "$src" "$dest"; then
    echo "Removing: $dest"
    rm "$dest"
    link_file "$src" "$dest"
    return
  fi

  echo "Backing up: $dest"
  mkdir -p "${backup_full_path%/*}"
  mv "$dest" "$backup_full_path"
  link_file "$src" "$dest"
}

walk_src() {
  local folder="$1"
  for file in "$folder"/*; do
    if [[ -L "$file" ]]; then
      continue
    elif [[ -d "$file" ]]; then
      walk_src "$file"
    elif [[ -f "$file" ]]; then
      sync_file "$file"
    fi
  done
}

walk_src "$src_abs_path"
