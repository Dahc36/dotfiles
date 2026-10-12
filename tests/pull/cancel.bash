source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\nexit 130\n' > bin/fzf
  chmod +x bin/fzf

  echo "old" > src/.differing
  echo "new" > home/.differing
  git init -q && git add src && git -c user.name=t -c user.email=t@t commit -q -m init

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/pull.bash > /dev/null
  local status=$?

  test_case "Exits non-zero" test "$status" != 0
  test_case "Src file is unchanged" test "$(cat src/.differing)" = "old"
}

in_temp_dir test_body
