source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "tracked" > src/.example
  echo "elsewhere" > home/.other
  ln -s "$tmp_dir/home/.other" home/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.example" > /dev/null

  test_case "Removes file from src" test ! -e src/.example
  test_case "Home symlink is untouched" test "$(readlink home/.example)" = "$tmp_dir/home/.other"
}

in_temp_dir test_body
