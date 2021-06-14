#!/bin/bash
# Pensado para hacer un include
# Recibe como primer parámetro ($1) la ruta al log file
# Se asume que ya está definido el lib_dir

stop_script_path="$DIRBIN/frenotp1.sh"
start_script_path="$DIRBIN/arrancotp1.sh"
temp_pid_locator_path="$DIRBIN/.pidprocesslocator"
EXECUTABLE="$DIRBIN/cuotatp.sh" 
		
# include log
. "$lib_dir/log.sh" "$1"

# include pprint
. "$lib_dir/pprint.sh"

function show_stop_program_guide() {
	if [ ! -f "$stop_script_path" ]
	then
		error_message "No se encontró el script para parar el sistema $(bold "frenotp1.sh")"
		log_err "No se encontró el script para parar el sistema frenotp1.sh"
		install_warning_message
	else
		echo -e $(info_message "Proceso ya corriendo (ppid: $(bold $(get_current_pid))). 
		Para poder cortar esa ejecución ejecute $(bold "bash $(echo "$stop_script_path" | sed "s-^$(pwd)/--")")")
		log_inf "Proceso ya corriendo (ppid: $(get_current_pid)) para poder cortar esa ejecución ejecute"
		log_inf "Para poder cortar esa ejecución ejecute bash $(echo "$stop_script_path" | sed "s-^$(pwd)/--")"
	fi
}

function show_start_program_guide() {
	if [ ! -f "$start_script_path" ]
	then
		echo "$start_script_path"
		error_message "No se encontró el script para arrancar el sistema $(bold "arrancotp1.sh")"
		log_err "No se encontró el script para arrancar el sistema frenotp1.sh"
		install_warning_message
	else
		echo -e $(info_message "Para poder arrancar el sistema, ejecute $(bold "bash $(echo "$start_script_path" | sed "s-^$(pwd)/--")")")
		log_inf "Para poder arrancar el sistema, ejecute bash $(echo "$start_script_path" | sed "s-^$(pwd)/--")"
	fi
}

function get_current_pid() {
    head -1 "$temp_pid_locator_path"
}

# @return 0 si el proceso principal está seteado y está corriendo
# 1 en caso contrario
function check_if_program_is_running() {
	if [[ -f "$temp_pid_locator_path" && \
          -e /proc/$(get_current_pid) ]]
	then
		return 0
	else
		return 1
	fi
}

function is_env_init() {
	if [ -z "$GRUPO" -o \
		 -z "$DIRCONF" -o \
	     -z "$DIRBIN" -o \
	     -z "$DIRMAE" -o \
	     -z "$DIRENT" -o \
	     -z "$DIRRECH" -o \
	     -z "$DIRPROC" -o \
	     -z "$DIRSAL" ]
	then
		error_message "El ambiento no está correctamente inicializado inicializado"
		info_message "Ejecute \"$(bold "$(echo "source $1/sisop/soinit.sh" | sed "s-^$(pwd)/--")")\" para inicializarlo"
		log_err "El ambiento no está correctamente inicializado inicializado"
		log_inf "Ejecute \"$(echo "source $1/sisop/soinit.sh" | sed "s-^$(pwd)/--")\" para inicializarlo"
		return 1
	fi
	return 0
}

function run_main_process() {
	"$EXECUTABLE" &
	TP_PID="$!"
	info_message "El sistema arrancó con pid: $(bold "$TP_PID")"
	log_inf "El sistema arrancó con pid: $TP_PID"
	echo $TP_PID > $temp_pid_locator_path
}

function stop_main_process() {
	log_inf "Se detiene el proceso principal con pid: $(get_current_pid)"
    kill $(get_current_pid) > /dev/null 2>&1
    rm "$temp_pid_locator_path"
}
