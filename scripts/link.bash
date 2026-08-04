#!/usr/bin/env bash

set -e
set -u
set -o pipefail

shopt -s nullglob
shopt -s dotglob

src_abs_path="$PWD/src"
timestamp=${TIMESTAMP:-$(date +%Y_%m_%d-%H_%M_%S)}
backup_path="$PWD/backup/$timestamp"


link_dest() {
  local src="$1"
  local dest="$2"
  echo "Linking: $dest -> $src"
  ln -s "$src" "$dest"
}

backup_dest() {
  local dest="$1"
  local backup_full_path="$backup_path${dest#"$HOME"}"
  echo "Backing up $dest"
  mkdir -p "${backup_full_path%/*}"
  mv "$dest" "$backup_full_path"
}

sync_src() {
  local src="$1"
  local dest="$HOME${src#"$src_abs_path"}"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "Already linked: $dest"
    return
  fi

  if [[ -L "$dest" ]]; then
    echo "Found unexpected symlink: $dest -> $(readlink "$dest")"
    backup_dest "$dest"
    link_dest "$src" "$dest"
    return
  fi

  if [[ ! -e "$dest" ]]; then
    mkdir -p "${dest%/*}"
    link_dest "$src" "$dest"
    return
  fi

  if cmp -s "$src" "$dest"; then
    echo "Same contents, removing $dest"
    rm "$dest"
    link_dest "$src" "$dest"
    return
  fi

  backup_dest "$dest"
  link_dest "$src" "$dest"
}

walk_src() {
  local folder="$1"
  for file in "$folder"/*; do
    if [[ -L "$file" ]]; then
      continue
    elif [[ -d "$file" ]]; then
      walk_src "$file"
    elif [[ -f "$file" ]]; then
      sync_src "$file"
    fi
  done
}

walk_src "$src_abs_path"
