source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\nexit 130\n' > bin/fzf
  chmod +x bin/fzf

  echo "tracked" > src/.example
  ln -s "$tmp_dir/src/.example" home/.example

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash > /dev/null
  local status=$?

  test_case "Exits non-zero" test "$status" != 0
  test_case "Src file is untouched" test -e src/.example
  test_case "Home symlink is untouched" test -L home/.example
}

in_temp_dir test_body
