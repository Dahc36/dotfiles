source tests/utils.bash

test_body() {
  local output status
  output=$(bash ../src/bin/specbranch 2> /dev/null)
  status=$?

  test_case "Prints nothing" test -z "$output"
  test_case "Exits non-zero" test "$status" != 0
}

in_temp_dir test_body
