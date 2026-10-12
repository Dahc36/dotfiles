source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir bin
  printf '#!/bin/sh\ncat > "%s/feed"\necho .differing\n' "$tmp_dir" > bin/fzf
  chmod +x bin/fzf

  echo "old" > src/.differing
  echo "new" > home/.differing
  echo "same" > src/.same
  echo "same" > home/.same
  echo "linked" > src/.linked
  ln -s "$tmp_dir/src/.linked" home/.linked
  echo "missing" > src/.missing
  git init -q && git add src && git -c user.name=t -c user.email=t@t commit -q -m init

  PATH="$tmp_dir/bin:$PATH" \
  HOME="$tmp_dir/home" \
  bash ../scripts/diff.bash > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "Lists only the differing file" test "$(cat feed)" = ".differing"
  test_case "Src file is untouched" test "$(cat src/.differing)" = "old"
  test_case "Home file is untouched" test "$(cat home/.differing)" = "new"
}

in_temp_dir test_body
