source tests/utils.bash

test_body() {
  git init -q
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m "base"

  local output status
  output=$(bash ../src/bin/specbranch --list docs/unattended-build.md)
  status=$?

  test_case "Prints nothing" test -z "$output"
  test_case "Exits zero" test "$status" = 0
}

in_temp_dir test_body
