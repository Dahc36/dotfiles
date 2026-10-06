source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.example
  echo "existing" > home/.example

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash > /dev/null

  test_case "Creates home file" test -L home/.example
  test_case "Home file links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"

  local backup="backup/test_backup/.example"
  test_case "Creates backup file" test -e "$backup"
  test_case "Backup file keeps its contents" test "$(cat "$backup")" = "existing"
}

in_temp_dir test_body
