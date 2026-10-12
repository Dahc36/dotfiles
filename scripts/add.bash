#!/usr/bin/env bash

set -euo pipefail

if [[ ! -d "$PWD/src" ]]; then
  echo "No src/ in $PWD, run from the repo root" >&2
  exit 1
fi

if (( $# > 0 )); then
  prompt="$1"
else
  if ! command -v fzpath > /dev/null; then
    echo "fzpath is required to choose a file" >&2
    exit 1
  fi
  prompt=$(fzpath "$HOME") || exit 1
  prompt=${prompt#"$HOME"}
  prompt=${prompt#/}
fi

if [[ -z "$prompt" ]]; then
  echo "No file selected" >&2
  exit 1
fi

if [[ "$prompt" == .. || "$prompt" == ../* ]]; then
  echo "File $HOME/$prompt is outside \$HOME, only files under \$HOME can be tracked"
  exit 1
fi

src="$PWD/src/$prompt"
dest="$HOME/$prompt"

if [[ -e "$src" && -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
  echo "Already tracked: $dest -> $src"
  exit 0
fi

if [[ -e "$src" ]]; then
  echo "File $src already exists, run make link to reconcile it with $dest"
  exit 1
fi

if [[ -L "$dest" ]]; then
  echo "File $dest is a symlink"
  exit 1
fi

if [[ ! -e "$dest" ]]; then
  echo "File $dest not found"
  exit 1
fi

if [[ -d "$dest" ]]; then
  echo "File $dest is a directory, only files can be tracked"
  exit 1
fi

echo "Moving $dest > $src"
mkdir -p "${src%/*}"
mv "$dest" "$src"
echo "Linking $dest -> $src"
ln -s "$src" "$dest"
