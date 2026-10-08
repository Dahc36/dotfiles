source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir home/.folder
  echo "contents" > home/.folder/example

  echo ".folder" | \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null
  local status=$?

  test_case "Exits 1" test "$status" = 1
  test_case "Doesn't create folder in src" test ! -e src/.folder
  test_case "Home folder is still a folder" test -d home/.folder
  test_case "Home folder is not a symlink" test ! -L home/.folder
  test_case "Home folder keeps its contents" test "$(cat home/.folder/example)" = "contents"
}

in_temp_dir test_body
