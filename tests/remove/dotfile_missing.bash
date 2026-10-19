source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "mine" > home/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.example" > /dev/null 2>&1
  local status=$?

  test_case "Exits 1" test "$status" = 1
  test_case "Home file is untouched" test "$(cat home/.example)" = "mine"
}

in_temp_dir test_body
