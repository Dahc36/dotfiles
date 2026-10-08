source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  mkdir -p backup/test_backup
  echo "original" > backup/test_backup/.example

  HOME="$tmp_dir/home" \
  bash ../scripts/restore.bash backup/test_backup > /dev/null
  local status=$?

  test_case "Exits 0" test "$status" = 0
  test_case "Home file is restored" test "$(cat home/.example)" = "original"
}

in_temp_dir test_body
