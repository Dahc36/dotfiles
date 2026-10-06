source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "system value" > home/.example

  echo ".example" | \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null

  test_case "Creates file in src" test -e src/.example
  test_case "File keeps same contents" test "$(cat src/.example)" = "system value"
  test_case "Creates symlink in home" test -L home/.example
  test_case "Home links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
}

in_temp_dir test_body
