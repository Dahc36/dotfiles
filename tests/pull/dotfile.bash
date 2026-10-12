source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\necho .differing\n' > bin/fzf
  chmod +x bin/fzf

  echo "old" > src/.differing
  echo "new" > home/.differing
  git init -q && git add src && git -c user.name=t -c user.email=t@t commit -q -m init

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/pull.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "Src file now matches home" test "$(cat src/.differing)" = "new"
  test_case "Home file is untouched" test "$(cat home/.differing)" = "new"
}

in_temp_dir test_body
