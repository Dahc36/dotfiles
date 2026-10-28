source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [code]\n---\n' > src/a.md

  local output status
  output=$(AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples missing)
  status=$?

  test_case "Prints nothing" test -z "$output"
  test_case "Exits non-zero" test "$status" != 0
}

in_temp_dir test_body
