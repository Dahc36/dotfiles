source tests/utils.bash

test_body() {
  git init -q
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m "base"
  git branch unattended-build/decide-skill

  local output
  output=$(bash ../src/bin/specbranch docs/unattended-build.md decide-skill)

  test_case "Prints a branch that already exists" test "$output" = "unattended-build/decide-skill"
}

in_temp_dir test_body
