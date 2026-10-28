source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [writing]\n---\n' > src/b.md
  printf -- '---\ntags: [code, writing]\n---\n' > src/a.md
  printf -- '---\ntags: [code]\n---\n' > src/c.md

  local output
  output=$(AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples writing)

  test_case "Prints matching paths, sorted" test "$output" = "$tmp_dir/src/a.md
$tmp_dir/src/b.md"
}

in_temp_dir test_body
