source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir src/.folder
  echo "contents" > src/.folder/example
  ln -s "$tmp_dir/src/.folder" home/.folder

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "File in src survives" test -f src/.folder/example
  test_case "File keeps its contents" test "$(cat src/.folder/example)" = "contents"
  test_case "Home folder link is untouched" test "$(readlink home/.folder)" = "$tmp_dir/src/.folder"
  test_case "Creates no backup" test ! -e backup
}

in_temp_dir test_body
