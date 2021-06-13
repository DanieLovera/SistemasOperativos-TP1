#!/bin/bash

if [ -z "$GRUPO" -o -z "$DIRCONF" -o -z "$DIRBIN" ]
then
    echo "no inicializado"
    # TODO: agregar mensaje + exit
fi

lib_dir="$GRUPO/original/lib"

# include log
. "$lib_dir/log.sh" "$DIRCONF/soinit.log"

# include run_utils
. "$lib_dir/run_utils.sh" "$DIRCONF/soinit.log"


function run() {
    check_if_program_is_running
	if [ $? -ne 0 ]
	then
		echo $(info_message "El sistema ya está detenido.")
		log_inf "El sistema ya está detenido"
	else
		stop_main_process
		echo $(success_message "Se pudo detener el sistema.")
		log_inf "Se pudo detener el sistema"
    fi
}

run