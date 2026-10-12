source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\necho "%s/home/.example"\n' "$tmp_dir" > bin/fzpath
  chmod +x bin/fzpath

  echo "system value" > home/.example

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null

  test_case "Creates file in src" test "$(cat src/.example)" = "system value"
  test_case "Home links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
}

in_temp_dir test_body
