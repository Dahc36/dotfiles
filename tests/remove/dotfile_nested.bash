source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir src/.zsh home/.zsh
  echo "tracked" > src/.zsh/git.zsh
  ln -s "$tmp_dir/src/.zsh/git.zsh" home/.zsh/git.zsh

  HOME="$tmp_dir/home" \
  bash ../scripts/remove.bash "src/.zsh/git.zsh" > /dev/null

  test_case "Removes file from src" test ! -e src/.zsh/git.zsh
  test_case "Prunes empty parent in src" test ! -e src/.zsh
  test_case "Keeps src itself" test -d src
  test_case "Removes symlink from home" test ! -L home/.zsh/git.zsh
  test_case "Keeps parent in home" test -d home/.zsh
}

in_temp_dir test_body
