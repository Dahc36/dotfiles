source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\nexit 130\n' > bin/fzpath
  chmod +x bin/fzpath

  echo "system value" > home/.example

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/add.bash > /dev/null
  local status=$?

  test_case "Exits non-zero" test "$status" != 0
  test_case "Doesn't create file in src" test ! -e src/.example
  test_case "Home file is untouched" test ! -L home/.example
}

in_temp_dir test_body
