#!/usr/bin/env bash

set -euo pipefail

if [[ ! -d "$PWD/src" ]]; then
  echo "No src/ in $PWD, run from the repo root" >&2
  exit 1
fi

read -r -p "File: ~/" prompt
src="$PWD/src/$prompt"
dest="$HOME/$prompt"

if [[ -e "$src" ]]; then
  echo "File $src already exists"
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
