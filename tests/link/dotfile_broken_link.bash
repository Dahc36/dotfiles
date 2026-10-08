source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.example
  ln -s "$tmp_dir/missing" home/.example

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash > /dev/null

  test_case "Home file links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
  test_case "Backs up the broken symlink" test -L backup/test_backup/.example
  test_case "Backup symlink keeps its pointer" \
    test "$(readlink backup/test_backup/.example)" = "$tmp_dir/missing"
}

in_temp_dir test_body
