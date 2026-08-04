source tests/utils

tmp_dir=$(setup_temp_dir)
# cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "new" > src/.example
ln -s "$tmp_dir/src/.example" home/.example

mkdir -p backup/test_backup
touch backup/test_backup/.example
echo "original" > backup/test_backup/.example

HOME="$tmp_dir/home" \
../scripts/restore.bash backup/test_backup

test_case "Home file is not a symlink anymore" test ! -L home/.example
test_case "Home file exists" test -e home/.example
test_case "Home file is restored" test "$(cat home/.example)" = "original"
test_case "Keeps the backup" test -e backup/test_backup/.example
