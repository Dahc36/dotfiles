source tests/utils.bash

test_body() {
  git init -q
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m "base"
  git branch unattended-build/spec-skill
  git branch unattended-build/decide-skill
  git branch unattended-build-notes/draft
  git branch other

  local output
  output=$(bash ../src/bin/specbranch --list docs/unattended-build.md)

  test_case "Prints only the run's branches, sorted" test "$output" = "unattended-build/decide-skill
unattended-build/spec-skill"
}

in_temp_dir test_body
