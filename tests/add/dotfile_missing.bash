source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo ".example" | \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null

  test_case "Doesn't create file in src" test ! -e src/.example
  test_case "Doesn't create symlink in home" test ! -L home/.example
  test_case "Doesn't create file in home" test ! -e home/.example
}

in_temp_dir test_body
