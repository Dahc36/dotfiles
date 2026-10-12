source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\necho "%s/home/../outside"\n' "$tmp_dir" > bin/fzpath
  chmod +x bin/fzpath

  echo "elsewhere" > outside

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null
  local status=$?

  test_case "Exits 1" test "$status" = 1
  test_case "Doesn't create file in src" test "$(ls -A src | wc -l | tr -d ' ')" = 0
  test_case "File outside home is untouched" test "$(cat outside)" = "elsewhere"
}

in_temp_dir test_body
