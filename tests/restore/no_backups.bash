source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\necho ""\n' > bin/fzf
  chmod +x bin/fzf

  echo "mine" > home/.example
  mkdir backup

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/restore.bash > /dev/null
  local status=$?

  test_case "Exits non-zero" test "$status" != 0
  test_case "Home file is untouched" test "$(cat home/.example)" = "mine"
}

in_temp_dir test_body
