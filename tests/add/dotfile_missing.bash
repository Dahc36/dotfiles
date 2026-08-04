source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

echo ".example" | \
HOME="$tmp_dir/home" \
../scripts/add.bash > /dev/null

test_case "Doesn't create file in src" test ! -e src/.example
test_case "Doesn't create symlink in home" test ! -L home/.example
test_case "Doesn't create file in home" test ! -e home/.example
