source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [code]\n---\n' > src/a.md
  printf -- '---\nname: untagged\n---\n' > src/b.md

  local status
  AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples code > /dev/null 2>&1
  status=$?

  test_case "Fails the run" test "$status" != 0
}

in_temp_dir test_body
