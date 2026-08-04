source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

touch src/.example
echo "root" > src/.example
mkdir other_folder
touch other_folder/.example
echo "other" > other_folder/.example
ln -s "$tmp_dir/other_folder/.example" home/.example

HOME="$tmp_dir/home" \
  TIMESTAMP="test_backup" \
  ../scripts/link.bash > /dev/null

test_case "Creates home file" test -L home/.example
test_case "Home file links to src " test "$(readlink home/.example)" = "$tmp_dir/src/.example"

test_case "Backup file is a symlink" test -L backup/test_backup/.example
test_case "Backup linked file exists" test -e backup/test_backup/.example
test_case "Backup symlink keeps its pointer" \
  test $(readlink backup/test_backup/.example) = "$tmp_dir/other_folder/.example"
