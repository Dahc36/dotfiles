source tests/utils.bash

test_body() {
  git init -q

  local output
  output=$(bash ../src/bin/specbranch docs/unattended-build.md decide-skill)

  test_case "Prints the last part under the prefix" test "$output" = "unattended-build/decide-skill"
}

in_temp_dir test_body
