#!/bin/bash


bin_dir="$(dirname "$(realpath "$0")")"
group_dir="$(dirname "$bin_dir")"
conf_dir="$group_dir/sisop"

lib_dir="$group_dir/original/lib"


# include log
. "$lib_dir/log.sh" "$conf_dir/soinit.log"

# include run_utils
. "$lib_dir/run_utils.sh" "$conf_dir/soinit.log"


function run() {
    check_and_show_if_env_is_init "$group_dir"
	if [ $? -ne 0 ]
	then
        exit 22
	fi

    check_if_program_is_running
	if [ $? -eq 0 ]
	then
		stop_main_process
		success_message "Se pudo detener el sistema."
		log_inf "Se pudo detener el sistema"
	else
		info_message "El sistema ya está detenido."
		log_inf "El sistema ya está detenido"
		show_start_program_guide
    fi
}

run
