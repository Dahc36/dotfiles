source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\nexit 2\n' > bin/fzf
  chmod +x bin/fzf

  echo "same" > src/.same
  echo "same" > home/.same
  git init -q && git add src && git -c user.name=t -c user.email=t@t commit -q -m init

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/diff.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
}

in_temp_dir test_body
