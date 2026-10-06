source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  local nested_folder=".folder/subfolder"
  mkdir -p "src/$nested_folder"
  echo "nested" > "src/$nested_folder/example"

  HOME="$tmp_dir/home" \
  bash ../scripts/link.bash > /dev/null

  local home_link="home/$nested_folder/example"
  test_case "Creates home file" test -L "$home_link"
  test_case "Home file links to src" test "$(readlink "$home_link")" = "$tmp_dir/src/$nested_folder/example"
}

in_temp_dir test_body
