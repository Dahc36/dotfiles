#!/usr/bin/env bash

set -euo pipefail

if [[ ! -d "$PWD/src" ]]; then
  echo "No src/ in $PWD, run from the repo root" >&2
  exit 1
fi

source "${BASH_SOURCE[0]%/*}/select_differing.bash"

path=$(select_differing) || exit 1

cp "$HOME/$path" "src/$path"
echo "Pulled ~/$path into src/$path"
