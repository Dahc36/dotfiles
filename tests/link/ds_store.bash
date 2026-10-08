source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "finder" > src/.DS_Store
  echo "root" > src/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/link.bash > /dev/null

  test_case "Doesn't link .DS_Store" test ! -e home/.DS_Store
  test_case "Still links the rest" test -L home/.example
}

in_temp_dir test_body
