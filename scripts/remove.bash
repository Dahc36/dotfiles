#!/usr/bin/env bash

set -euo pipefail

if [[ ! -d "$PWD/src" ]]; then
  echo "No src/ in $PWD, run from the repo root" >&2
  exit 1
fi

select_tracked() {
  if ! command -v fzf > /dev/null; then
    echo "fzf is required to choose a file" >&2
    return 1
  fi

  find src -type f ! -name .DS_Store | sort | fzf
}

prune_empty_parents() {
  local folder="${1%/*}"
  while [[ "$folder" != "$PWD/src" ]] && rmdir "$folder" 2> /dev/null; do
    folder="${folder%/*}"
  done
}

if (( $# > 0 )); then
  path="$1"
else
  path=$(select_tracked) || exit 1
fi

if [[ -z "$path" ]]; then
  echo "No file selected" >&2
  exit 1
fi

if [[ "$path" != src/* ]]; then
  echo "File $path is outside src/" >&2
  exit 1
fi

src="$PWD/$path"

if [[ -d "$src" ]]; then
  echo "File $path is a directory, only files can be removed" >&2
  exit 1
fi

if [[ ! -e "$src" ]]; then
  echo "File $path not found" >&2
  exit 1
fi

rm "$src"
prune_empty_parents "$src"
echo "Removed $path"

dest="$HOME/${path#src/}"
home_path="~${dest#"$HOME"}"

if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
  rm "$dest"
  echo "Unlinked $home_path"
elif [[ -e "$dest" || -L "$dest" ]]; then
  echo "Left $home_path alone, it is not a link to $path"
fi
