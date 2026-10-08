source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "value" > src/.example
  ln -s "$tmp_dir/src/.example" home/.example

  echo ".example" | \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "File in src remains" test "$(cat src/.example)" = "value"
  test_case "Home still links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
}

in_temp_dir test_body
