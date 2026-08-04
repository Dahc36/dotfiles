source tests/utils

tmp_dir=$(setup_temp_dir)
cleanup "$tmp_dir"

cd "$tmp_dir"
nested_folder=".folder/subfolder"
mkdir -p "src/$nested_folder"
touch "src/$nested_folder/example"
echo "nested" > "src/$nested_folder/example"

HOME="$tmp_dir/home" \
../scripts/link.bash > /dev/null

home_link="home/$nested_folder/example"
test_case "Creates home file" test -L "$home_link"
test_case "Home file links to src " test "$(readlink "$home_link")" == "$tmp_dir/src/$nested_folder/example"
