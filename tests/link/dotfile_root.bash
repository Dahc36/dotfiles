source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/link.bash > /dev/null

  test_case "Creates home file" test -L home/.example
  test_case "Home file links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
}

in_temp_dir test_body
