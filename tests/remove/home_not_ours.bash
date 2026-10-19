source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "tracked" > src/.example
  echo "mine" > home/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.example" > /dev/null

  test_case "Removes file from src" test ! -e src/.example
  test_case "Home file is untouched" test "$(cat home/.example)" = "mine"
}

in_temp_dir test_body
