source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"
cd "$tmp_dir"

mkdir home/folder
touch home/folder/.example
echo "system value" > home/folder/.example

echo "folder/.example" | \
HOME="$tmp_dir/home" \
../scripts/add.bash > /dev/null

test_case "Creates file in src" test -e src/folder/.example
test_case "File keeps same contents" test "$(cat src/folder/.example)" = "system value"
test_case "Creates symlink in home" test -L home/folder/.example
test_case "Home links to src" test "$(readlink home/folder/.example)" = "$tmp_dir/src/folder/.example"
