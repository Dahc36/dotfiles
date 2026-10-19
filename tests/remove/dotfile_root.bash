source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "tracked" > src/.example
  ln -s "$tmp_dir/src/.example" home/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.example" > /dev/null

  test_case "Removes file from src" test ! -e src/.example
  test_case "Removes symlink from home" test ! -L home/.example
  test_case "Nothing is left in home" test ! -e home/.example
}

in_temp_dir test_body
