source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "root" > src/.example
touch home/.example
echo "existing" > home/.example

HOME="$tmp_dir/home" \
TIMESTAMP="test_backup" \
../scripts/link.bash > /dev/null

test_case "Creates home file" test -L home/.example
test_case "Home file links to src " test "$(readlink home/.example)" = "$tmp_dir/src/.example"

backup="backup/test_backup/.example"
test_case "Creates backup file" test -e "$backup"
test_case "Backup file keeps its contents" test "$(cat "$backup")" = "existing"
