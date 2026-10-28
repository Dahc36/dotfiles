source tests/utils.bash

test_body() {
  local tmp_dir="$1"

  printf -- '---\ntags: [code]\n---\n' > src/a.md

  local output
  output=$(AIPRINCIPLES_DIR="$tmp_dir/src" bash ../src/bin/aiprinciples --dir)

  test_case "Prints the principles folder" test "$output" = "$tmp_dir/src"
}

in_temp_dir test_body
