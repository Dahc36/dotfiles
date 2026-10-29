source tests/utils.bash

test_body() {
  local repo_dir
  repo_dir=$(cd .. && pwd)
  ln -s "$repo_dir/src/bin/aiprinciples" home/aiprinciples

  local output
  output=$(env -u AIPRINCIPLES_DIR bash home/aiprinciples --dir)

  test_case "Through a symlink, prints the repo's principles folder" test "$output" = "$repo_dir/principles"
}

in_temp_dir test_body
