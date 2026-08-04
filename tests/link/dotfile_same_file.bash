source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "root" > src/.example
touch home/.example
echo "root" > home/.example

HOME="$tmp_dir/home" \
TIMESTAMP="test_backup" \
../scripts/link.bash > /dev/null

test_case "Creates link" test -L home/.example
test_case "Links to src " test "$(readlink home/.example)" = "$tmp_dir/src/.example"

test_case "Creates no backup" test ! -d backup/test_backup/.example
