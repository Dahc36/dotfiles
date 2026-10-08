source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "value" > src/.example
  echo "value" > home/.example

  echo ".example" | \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null
  local status=$?

  test_case "Exits 1" test "$status" = 1
  test_case "File in src remains" test -e src/.example
  test_case "Doesn't create symlink in home" test ! -L home/.example
  test_case "File in home remains" test -e home/.example
  test_case "File keeps same contents" test "$(cat home/.example)" = "$(cat src/.example)"
}

in_temp_dir test_body
