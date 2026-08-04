source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "root" > src/.example

HOME="$tmp_dir/home" \
../scripts/link.bash > /dev/null

test_case "Creates home file" test -L home/.example
test_case "Home file links to src" test "$(readlink home/.example)" = "$tmp_dir/src/.example"
