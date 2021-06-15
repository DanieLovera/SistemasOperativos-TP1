test_dir="$(dirname "$(realpath "$0")")"
group_dir="$(dirname "$test_dir")"
conf_dir="$group_dir/sisop"

# include pprint
. "$group_dir/original/lib/pprint.sh"

TEST_FILE_NAME="$1"

TEST_ID="$(echo "$TEST_FILE_NAME" | cut -d"_" -f1)"

function uninit() {
    unset GRUPO
    unset DIRCONF
    unset DIRBIN
    unset DIRNAME
    unset DIRMAE
    unset DIRENT
    unset DIRRECH
    unset DIRPROC
    unset DIRSAL
}

function unistall() {
    [ -f "$conf_dir/sotp1.conf" ] && rm "$conf_dir/sotp1.conf"
    remove_logs
}

function remove_logs() {
    [ -f "$conf_dir/*.log" ] && rm "$conf_dir/"*.log    
}

function make_test_dir() {
    [ -d "$test_dir/$TEST_ID" ] && rm -r "$test_dir/$TEST_ID"
    mkdir "$test_dir/$TEST_ID"
}

function show_log() {
    cat "$test_dir/$TEST_ID/$1"
}

function save_logs() {
    cp "$conf_dir/"*.log "$test_dir/$TEST_ID"
}

function save_conf() {
    cp "$conf_dir/sotp1.conf" "$test_dir/$TEST_ID"
}

function remove_org_logs() {
    rm "$conf_dir/"*.log
}

function fast_install() {
    bash "$conf_dir/sotp1.sh" -y
}

function regular_install() {
    bash "$conf_dir/sotp1.sh"
}

function init_env() {
    source "$conf_dir/soinit.sh"
}

function test_stop_main_process() {
    bash "$DIRBIN/frenotp1.sh"
}

function test_start_main_process() {
    bash "$DIRBIN/arrancotp1.sh"
}

function show_result() {
    local -n l_errors=$2
    if [ $1 -eq 0 ]
    then
        success_message "$(bold "$TEST_FILE_NAME")"
    else
        error_message "$(bold "$TEST_FILE_NAME")"
        for error in "${l_errors[@]}"
        do
            echo -e "$(error_message "... \t $error")"
        done
    fi

}