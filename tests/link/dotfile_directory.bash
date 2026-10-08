source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.example
  mkdir home/.example
  echo "inside" > home/.example/file

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "Home directory is untouched" test -d home/.example
  test_case "Home directory keeps its contents" test "$(cat home/.example/file)" = "inside"
  test_case "Creates no backup" test ! -e backup/test_backup
}

in_temp_dir test_body
