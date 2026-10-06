source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "new" > src/.example
  ln -s "$tmp_dir/src/.example" home/.example

  mkdir -p backup/test_backup
  echo "original" > backup/test_backup/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/restore.bash backup/test_backup

  test_case "Home file is not a symlink anymore" test ! -L home/.example
  test_case "Home file exists" test -e home/.example
  test_case "Home file is restored" test "$(cat home/.example)" = "original"
}

in_temp_dir test_body
