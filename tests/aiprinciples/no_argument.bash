source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [code]\n---\n' > src/a.md
  printf -- '---\ntags: [writing]\n---\n' > src/b.md

  local output
  output=$(AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples)

  test_case "Prints every principle" test "$output" = "$tmp_dir/src/a.md
$tmp_dir/src/b.md"
}

in_temp_dir test_body
