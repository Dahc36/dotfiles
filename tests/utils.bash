in_temp_dir() {
  local body="$1" path scenario suite tmp_dir status

  # name the dir after the scenario: tests/link/dotfile_backup.bash -> link-dotfile_backup
  path="${0%.bash}"
  scenario="${path##*/}"
  suite="${path%/*}"
  suite="${suite##*/}"

  tmp_dir=$(mktemp -d "$PWD/test.$(date +%Y_%m_%d-%H_%M_%S).$suite-$scenario.XXXX")
  mkdir "$tmp_dir/home" "$tmp_dir/src"

  ( cd "$tmp_dir" || exit 1; "$body" "$tmp_dir" )
  status=$?

  if (( status == 0 )); then
    rm -rf "$tmp_dir"
  else
    echo "    ↳ kept $tmp_dir"
  fi

  return $status
}

test_case() {
  local desc="$1"
  shift

  printf '    • %s ' "$desc"

  if "$@"; then
    echo ✔
  else
    echo ❌
    exit 1
  fi
}
