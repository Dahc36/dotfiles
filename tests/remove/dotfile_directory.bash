source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir src/.folder
  echo "tracked" > src/.folder/example

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.folder" > /dev/null 2>&1
  local status=$?

  test_case "Exits 1" test "$status" = 1
  test_case "Src folder keeps its contents" test "$(cat src/.folder/example)" = "tracked"
}

in_temp_dir test_body
