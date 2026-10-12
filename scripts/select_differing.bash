select_differing() {
  if ! command -v fzf > /dev/null; then
    echo "fzf is required to choose a file" >&2
    exit 1
  fi

  local differing=()
  local file path
  while IFS= read -r file; do
    path="${file#src/}"
    if [[ -f "$HOME/$path" && ! -L "$HOME/$path" ]] && ! cmp -s "$file" "$HOME/$path"; then
      differing+=("$path")
    fi
  done < <(git ls-files src)

  if (( ${#differing[@]} == 0 )); then
    echo "Nothing differs"
    exit 0
  fi

  printf '%s\n' "${differing[@]}" | fzf
}
