#!/bin/bash
# include pprint
. $(dirname "$0")/pprint.sh

# include log
. $(dirname "$0")/log.sh "soinit.log"

conf_file_path="$(dirname "$0")/sotp1.conf"
install_script_path="$(dirname "$0")/sotp1.sh"

# Lista con los datos del archivo de configuracion final.
conf_directories=("$group_dir" "$conf_file_path" "$exe_dir" "$sys_tables_dir" 
				  "$news_input_dir" "$rejected_files_dir" "$lots_dir" 
				  "$results_dir")
CONFIG_ARG_LEN=8

# function log() {
# 	echo "$1-$(date "+%d/%m/%Y %H:%M:%S")-$2-$(whoami)" >> soinit.log
# }

function check_install_script() {
	if [ -f "${install_script_path}" ]
	then
		echo $(info_message "Proceda a ejecutar el comando $(bold "bash ${install_script_path##*/}") para instalar el sistema.")
		log_inf "Proceda a ejecutar bash ${install_script_path##*/}"
	else
		echo $(error_message "No se encontró el archivo $(bold "$install_script_path")")
		log_err "No se encontró el archivo ${install_script_path}"

		echo $(info_message "Proceda a realizar la descarga del sistema indicada en $(bold "README.md").")
		log_inf "Proceda a realizar la descarga del sistema indicada en README.md."
	fi
}

# Devuelve 1 en caso de que falle el conf_file 0 en caso de todo ok
function check_conf_file() {
	if [ ! -f  ${conf_file_path} ]
	then
		echo $(error_message "No se encontró el archivo $(bold "${conf_file_path}")")
		log_err "No se encontró el archivo ${conf_file_path}"
		return 1
	fi
	return 0
}

# Carga el archivo de configuracion a memoria en un array.
# TODO: Ver si sacar o no
function load_conf_directories() {
	local backIFS=$IFS # TODO: Creo que es una mala práctica
	local counter=0
	while IFS='' read -r line || [[ -n "${line}" ]]
	do
		local path=$(echo "${line}" | sed s/^.*-//)

		if [ ${path} != $(whoami) ]
		then
			conf_directories[counter]=$(echo "${line}" | sed s/^.*-//)
			
			counter=$((counter + 1))
			# counter=$((${counter} + 1))

		fi
	done < $1
	IFS=$backIFS
}

# Carga el archivo de configuracion a memoria en un array.
# @return Devuelve 0 en caso de que pueda cargar todas las variables
# 1 en caso contrario
function load_conf_directories() {
	local counter=0
	while [ $counter -lt $CONFIG_ARG_LEN ]
	do
		conf_directories[counter]=$(sed -n "$(($counter + 1)) p" "$1" | sed "s/^.*-//")
		if [ -z $conf_directories[counter] ]
		then
			return 1
		fi
		counter=$((counter + 1))
	done
	return 0
}

# Comprueba si hay un directorio faltante
# @return Devuelve 1 en caso de que falte un directorio
# principal y 0 en caso contrario.
function is_missing_directory() {
	if [[ ! -d "${conf_directories[4]}/ok" ]]
	then
		return 1
	fi

	for directory in "${conf_directories[@]}"
	do
    	if [[ ! -d "${directory}" ]] 
    	then
       		return 1
    	fi
	done
	return 0
}

# Comprueba si hay un archivo de instalacion faltante
# @return Devuelve 1 en caso de que falte un archivo
# principal y 0 en caso contrario.
function is_missing_file() {
	# TODO: ACA TAMBIEN HAY QUE AGREGAR REVISAR LOS BINARIOS DEL PASO 5
	if [[ ! -f "${conf_directories[3]}/financiacion.txt" || \
		  !	-f "${conf_directories[3]}/terminales.txt" ]]
	then
		return 1
	fi
	return 0
}

# @return 0 en caso de que todos los directorios sean distintos.
# 1 en caso contrario
function are_distinct_directories() {
	for (( i=0; i<$CONFIG_ARG_LEN; i++))
	do
		for (( j=$(( i + 1 )); j<$CONFIG_ARG_LEN; j++))
		do
			if [ "${conf_directories[$i]}" = "${conf_directories[$j]}" ]
			then
				return 1
			fi
		done
	done
	return 0
}

# Devuelve 0 si todo ok o 1 en caso contrario
function check_system() {
	local system_status=0
	load_conf_directories "${conf_file_path}"
	local could_load_conf=$?

	is_missing_directory
	local missing_directory_status=$?

	is_missing_file
	local missing_file_status=$?

	are_distinct_directories
	local distinct_directories=$?

	if [[ $could_load_conf -eq 1 || \
		  $missing_directory_status -eq 1 || \
		  $missing_file_status -eq 1 ||\
		  $distinct_directories -eq 1 ]]
	then
		system_status=1
		echo $(error_message "Sistema dañado")
		log_err "Sistema dañado"
	else
		echo $(info_message "Directorios del sistema... $(display_ok)")
		log_inf "Directorios del sistema ok"
		echo $(info_message "Archivos del sistema... $(display_ok)")
		log_inf "Archivos del sistema ok"
	fi
	return $system_status
}

# Da permisos de lectura a los archivos del sistema
function grant_permissions() {
	# AGREGAR LUEGO LOS PERMISOS DE LOS EJECUTABLES DEL PASO 5
	chmod 444 "${conf_directories[3]}/financiacion.txt"
	chmod 444 "${conf_directories[3]}/terminales.txt"
}

# @return 0 en caso de que todos los archivos tengan permiso de lectura
# 1 en caso contrario.
function check_permissions() {
	# AGREGAR LUEGO LOS PERMISOS DE LOS EJECUTABLES DEL PASO 5
	if [ ! -r "${conf_directories[3]}/financiacion.txt" ]
	then 
		return 1
	fi

	if [ ! -r "${conf_directories[3]}/terminales.txt" ]
	then 
		return 1
	fi

	echo $(info_message "Permisos de tablas maestras y ejecutables...$(display_ok)")
	log_inf "Permisos de tablas maestras y ejecutables ok"
	return 0	
}

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
		return 1
	fi

	check_permissions
	if [ $? -ne 0 ]
	then
		grant_permissions
		check_permissions
		if [ $? -ne 0 ]
		then
			return 1
		fi
	fi
	return 0
}

function run() {
	check_installation
	if [ $? -eq 0 ]
	then
		# echo "${GRUPO}" # VACIO
		check_env_configuration
		if [ $? -ne 0 ]
		then
			set_environments_vars
		fi
		if [ $? -eq 0 ]
		then
			echo $(success_message "Se inició el ambiente correctamente")
			log_inf "Se inició el ambiente correctamente"
		fi
		# echo "${GRUPO}"
		# bash test.sh # TODO: temporal?
	else
		check_install_script
	fi
	
	# TODO: Falta invocar el proceso principal
}

run