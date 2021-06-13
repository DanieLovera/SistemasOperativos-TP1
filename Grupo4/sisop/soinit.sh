#!/bin/bash
# Como este script se tiene que ejecutar con `source` o con `. <script>`
# no se puede usar $0.
function real_path() {
	echo $(dirname $(realpath ${BASH_SOURCE[0]}))
}

conf_dir="$(real_path)"
group_dir="$(dirname $conf_dir)"
lib_dir="$group_dir/original/lib"

# include pprint
. "$lib_dir/pprint.sh"

# include log
. "$lib_dir/log.sh" "$conf_dir/soinit.log"

conf_file_path="$conf_dir/sotp1.conf"
install_script_path="$conf_dir/sotp1.sh"

# include conf_utils
. "$lib_dir/conf_utils.sh"


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
	export DIRMAE
	export DIRENT
	export DIRRECH
	export DIRPROC
	export DIRSAL
	check_env_configuration
	if [ $? -eq 0 ]
	then
		echo $(info_message "Variables de ambiente configuradas")
		log_inf "Variables de ambiente configuradas"
		# include run_utils
		. "$lib_dir/run_utils.sh" "$conf_dir/soinit.log"
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

function run() {
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
			check_if_program_is_running
			if [ $? -eq 0 ]
			then
				show_stop_program_guide
				return 0
			fi
			show_start_program_guide
			return 0
		fi

		run_main_process

	else
		check_install_script
	fi

}

run
