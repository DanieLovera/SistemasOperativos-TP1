#!/bin/bash
# Como este scrip se tiene que ejecutar con `source` o con `. <script>`
# no se puede usar $0.
function real_path() {
	echo $(dirname $(realpath ${BASH_SOURCE[0]}))
}

# include pprint
. "$(real_path)/pprint.sh"

# include log
. "$(real_path)/log.sh" "$(real_path)/soinit.log"

conf_file_path="$(real_path)/sotp1.conf"
install_script_path="$(real_path)/sotp1.sh"

# Puedo usar $DIRBIN porque sé que está incializado el ambiente
stop_script_path="$DIRBIN/frenotp1.sh"
start_script_path="$DIRBIN/arrancotp1.sh"
EXECUTABLE="$DIRBIN/parser.sh" # Debería ser cuotatp

# include conf_utils
. "$(real_path)/conf_utils.sh"

# @return 0 en caso de que el entorno coincida con la configuración del
# archivo de configuración, 1 en caso contrario.
function check_env_configuration() {
	if [[ "$GRUPO" = "${conf_directories[0]}" && \
		  "$DIRCONF" = "${conf_directories[1]}" && \
		  "$DIRBIN" = "${conf_directories[2]}" && \
		  "$DIRMAE" = "${conf_directories[3]}" && \
		  "$DIRENT" = "${conf_directories[4]}" && \
		  "$DIRRECH" = "${conf_directories[5]}" && \
		  "$DIRPROC" = "${conf_directories[6]}" && \
		  "$DIRSAL" = "${conf_directories[7]}" ]]
	then
		return 0
	fi
	return 1
}

function set_environments_vars() {
	GRUPO="${conf_directories[0]}"
	DIRCONF="${conf_directories[1]}"
	DIRBIN="${conf_directories[2]}"
	DIRMAE="${conf_directories[3]}"
	DIRENT="${conf_directories[4]}"
	DIRRECH="${conf_directories[5]}"
	DIRPROC="${conf_directories[6]}"
	DIRSAL="${conf_directories[7]}"
	export GRUPO
	export DIRCONF
	export DIRBIN
	export DIRNAME
	export DIRENT
	export DIRRECH
	export DIRPROC
	export DIRSAL
	check_env_configuration
	if [ $? -eq 0 ]
	then
		echo $(info_message "Variables de ambiente configuradas")
		log_inf "Variables de ambiente configuradas"
		return 0
	else
		echo $(error_message "No se pudo configurar el ambiente")
		log_err "No se pudo configurar el ambiente"
		return 1
	fi
}

# @return 0 en caso de que el sistema esté correctamente instalado.
# 1 en caso contrario 
function check_installation() {
	check_conf_file
	if [ $? -ne 0 ]
	then
		return 1
	fi

	check_system
	if [ $? -ne 0 ]
	then
		echo $(error_message "Sistema dañado")
		log_err "Sistema dañado"
		return 1
	else
		echo $(info_message "Directorios del sistema... $(display_ok)")
		log_inf "Directorios del sistema ok"
		echo $(info_message "Archivos del sistema... $(display_ok)")
		log_inf "Archivos del sistema ok"
	fi

	check_permissions
	if [ $? -ne 0 ]
	then
		grant_permissions
		check_permissions
		if [ $? -ne 0 ]
		then
			echo $(error_message "No se tienen permisos en los archivos")
			log_err "No se tienen permisos de lectura en los archivos"
			return 1
		fi
	fi
	return 0
}

# @return 0 si el proceso principal está seteado y está corriendo
# 1 en caso contrario
function check_if_program_running() {
	if [[ -n $TP_PID && -e /proc/$TP_PID ]]
	then
		return 0
	else
		return 1
	fi
}

function show_stop_program_guide() {
	if [ ! -f "$stop_script_path" ]
	then
		install_warning_message
	else
		echo -e $(info_message "Proceso ya corriendo (ppid: $(bold $TP_PID)). 
		Para poder cortar esa ejecución ejecute $(bold "bash $(echo "$stop_script_path" | sed "s-^$(pwd)/--")")")
		log_inf "Proceso ya corriendo (ppid: $TP_PID) para poder cortar esa ejecución ejecute"
		log_inf "Para poder cortar esa ejecución ejecute bash $(echo "$stop_script_path" | sed "s-^$(pwd)/--")"
	fi
}

function show_start_program_guide() {
	if [ ! -f "$start_script_path" ]
	then
		install_warning_message
	else
		echo -e $(info_message "Ambiente ya configurado. 
		Para poder cortar esa ejecución ejecute $(bold "bash $(echo "$start_script_path" | sed "s-^$(pwd)/--")")")
		log_inf "Ambiente ya configurado."
		log_inf "Para poder cortar esa ejecución ejecute bash $(echo "$start_script_path" | sed "s-^$(pwd)/--")"
	fi
}

function run_tp_scripts() {
	"$EXECUTABLE" &
	TP_PID="$!"
	export TP_PID
}

function run() {
	check_if_program_running
	if [ $? -eq 0 ]
	then
		show_stop_program_guide
		return 0
	fi

	check_installation
	if [ $? -eq 0 ]
	then
		check_env_configuration
		if [ $? -ne 0 ]
		then
			set_environments_vars
			if [ $? -eq 0 ]
			then
				echo $(success_message "Se inició el ambiente correctamente")
				log_inf "Se inició el ambiente correctamente"
			fi
		else
			show_start_program_guide
			return 0
		fi

		# TODO: Falta invocar el proceso principal
		run_tp_scripts


	else
		check_install_script
	fi

}

run
