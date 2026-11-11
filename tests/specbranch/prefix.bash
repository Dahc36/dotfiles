source tests/utils.bash

test_body() {
  local output
  output=$(bash ../src/bin/specbranch docs/unattended-build.md)

  test_case "Prints the spec's file name without its extension" test "$output" = "unattended-build"
}

in_temp_dir test_body
