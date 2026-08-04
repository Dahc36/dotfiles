source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch home/.example
echo "system value" > home/.example

echo ".example" | \
HOME="$tmp_dir/home" \
../scripts/add.bash > /dev/null

test_case "Creates file in src" test -e src/.example
test_case "File keeps same contents" test "$(cat src/.example)" = "system value"
test_case "Creates symlink in home" test -L home/.example
test_case "Home links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
