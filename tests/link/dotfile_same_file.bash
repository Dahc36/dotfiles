source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.example
  echo "root" > home/.example

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash > /dev/null

  test_case "Creates link" test -L home/.example
  test_case "Links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"

  test_case "Creates no backup" test ! -e backup/test_backup/.example
}

in_temp_dir test_body
