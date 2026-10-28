source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [code, writing]\n---\n' > src/a.md
  printf -- '---\ntags: [writing]\n---\n' > src/b.md
  printf -- '---\ntags: [other]\n---\n' > src/c.md

  local output
  output=$(AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples code writing)

  test_case "Prints the union, deduplicated" test "$output" = "$tmp_dir/src/a.md
$tmp_dir/src/b.md"
}

in_temp_dir test_body
