#!/bin/bash

bin_dir="$(dirname "$(realpath $0)")"
group_dir="$(dirname $bin_dir)"
conf_dir="$group_dir/sisop"

lib_dir="$group_dir/original/lib"

# include run_utils
. "$lib_dir/run_utils.sh" "$conf_dir/soinit.log"


function run() {
    is_env_init "$group_dir"
	if [ $? -ne 0 ]
	then
        exit 22
	fi
    check_if_program_is_running
	if [ $? -ne 0 ]
	then
        run_main_process
	else
		show_stop_program_guide
    fi
}

run

exit 0
