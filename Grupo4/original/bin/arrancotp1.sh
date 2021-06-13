#!/bin/bash
if [ -z "$GRUPO" -o -z "$DIRCONF" -o -z "$DIRBIN" ]
then
    echo "no inicializado"
    # TODO: agregar mensaje + exit
fi

lib_dir="$GRUPO/original/lib"

# include run_utils
. "$lib_dir/run_utils.sh" "$DIRCONF/soinit.log"


function run() {
    check_if_program_running
	if [ $? -eq 0 ]
	then
		show_stop_program_guide
	else
        run_main_process
    fi
}

run