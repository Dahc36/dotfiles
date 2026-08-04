source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "value" > src/.example
touch home/.example
echo "value" > home/.example

echo ".example" | \
HOME="$tmp_dir/home" \
../scripts/add.bash > /dev/null

test_case "File in src remains" test -e src/.example
test_case "Doesn't create symlink in home" test ! -L home/.example
test_case "File in home remains" test -e home/.example
test_case "File keeps same contents" test "$(cat home/.example)" = "$(cat src/.example)"
