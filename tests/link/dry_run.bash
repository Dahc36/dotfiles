source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  echo "root" > src/.absent
  echo "root" > src/.differing
  echo "existing" > home/.differing
  echo "root" > src/.identical
  echo "root" > home/.identical
  echo "root" > src/.foreign
  ln -s "$tmp_dir/elsewhere" home/.foreign

  HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  bash ../scripts/link.bash --dry-run > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "Absent target stays absent" test ! -e home/.absent
  test_case "Differing file stays a file" test ! -L home/.differing
  test_case "Differing file keeps its contents" test "$(cat home/.differing)" = "existing"
  test_case "Identical file stays a file" test ! -L home/.identical
  test_case "Foreign symlink keeps its pointer" test "$(readlink home/.foreign)" = "$tmp_dir/elsewhere"
  test_case "Creates no backup" test ! -e backup
}

in_temp_dir test_body
