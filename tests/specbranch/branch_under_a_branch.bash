source tests/utils.bash

test_body() {
  git init -q
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m "base"
  git branch unattended-build/decide

  local output status
  output=$(bash ../src/bin/specbranch docs/unattended-build.md decide/skill 2> /dev/null)
  status=$?

  test_case "Prints nothing" test -z "$output"
  test_case "Exits non-zero" test "$status" != 0
}

in_temp_dir test_body
