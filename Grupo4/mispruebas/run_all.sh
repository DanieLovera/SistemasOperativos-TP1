test_dir="$(dirname "$(realpath "$0")")"
cd "$test_dir"
ls | grep -E test[0-9]+_.* | xargs -L1 bash
