#!/bin/bash

conf_file_path="$(pwd)/sotp1.conf"
install_script_path="$(pwd)/sotp1.sh"

# Lista con los datos del archivo de configuracion final.
conf_directories=("$group_dir" "$conf_file_path" "$exe_dir" "$sys_tables_dir" "$news_input_dir" "$rejected_files_dir" "$lots_dir" "$results_dir")

function log() {
	echo "$1-$(date "+%d/%m/%Y %H:%M:%S")-$2-$(whoami)" >> soinit.log
}

function check_install_script() {
	if [ -f "${install_script_path}" ]
	then
		echo "Proceda a ejecutar el comando 'bash ${install_script_path##*/}' para instalar el sistema."
		log "INF" "Proceda a ejecutar bash ${install_script_path##*/}"
	else
		echo "No se encontro el archivo ${install_script_path}"
		log "ERR" "No se encontro el archivo ${install_script_path}"
		echo "Proceda a realizar la descarga del sistema indicada en README.md."
		log "INF" "Proceda a realizar la descarga del sistema indicada en README.md."
	fi
}

# Devuelve 1 en caso de que falle el conf_file 0 en caso de todo ok
function check_conf_file() {
	if [ ! -f  ${conf_file_path} ]
	then
		echo "No se contro el archivo ${conf_file_path}"
		log "ERR" "No se contro el archivo ${conf_file_path}"
		check_install_script
		return 1
	fi
	return 0
}

# Carga el archivo de configuracion a memoria en un array.
function load_conf_directories() {
	local backIFS=$IFS
	local counter=0
	while IFS='' read -r line || [[ -n "${line}" ]]
	do
		local path=$(echo "${line}" | sed s/^.*-//)
		if [ ${path} != $(whoami) ]
		then
			conf_directories[counter]=$(echo "${line}" | sed s/^.*-//)
			counter=$((${counter} + 1))
		fi
	done < $1
	IFS=$backIFS
}

# Comprueba si hay un directorio faltante
# @return Devuelve 1 en caso de que falte un directorio
# principal y 0 en caso contrario.
function is_missing_directory() {
	for directory in "${conf_directories[@]}"
	do
    	if [[ ! -d "${directory}" || ! -d "${conf_directories[4]/ok}" ]] 
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
	# ACA TAMBIEN HAY QUE AGREGAR REVISAR LOS BINARIOS DEL PASO 5
	if [[ ! -f "${conf_directories[3]}/financiacion.txt" || \
		  !	-f "${conf_directories[3]}/terminales.txt" ]]
	then
		return 1
	fi
	return 0
}

# Devuelve 0 si todo ok o 1 en caso contrario
function check_system() {
	local system_status=0
	load_conf_directories "${conf_file_path}"
	is_missing_directory
	local missing_directory_status=$?
	is_missing_file
	local missing_file_status=$?

	if [[ ${missing_directory_status} -eq 1 || ${missing_file_status} -eq 1 ]]
	then
		${system_status}=1
		echo "Sistema dañado"
		log "ERR" "Sistema dañado"
		check_install_script
	else
		echo "Directorios del sistema ok"
		log "INF" "Directorios del sistema ok"
		echo "Archivos del sistema ok"
		log "INF" "Archivos del sistema ok"
	fi
	return ${system_status}
}

function check_permissions() {
	# VER SI ES NECESARIO COMPROBAR ANTES 
	chmod 444 "${conf_directories[3]}/financiacion.txt"
	chmod 444 "${conf_directories[3]}/terminales.txt"
	# AGREGAR LUEGO LOS PERMISOS DE LOS EJECUTABLES DEL PASO 5
	echo "Permisos de tablas maestras y ejecutables ok"
	log "ING" "Permisos de tablas maestras y ejecutables ok"
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
	echo "Variables de ambiente configuradas"
	log "INF" "Variables de ambiente configuradas"
}

function run() {
	#check_conf_file
	#if [ $? -eq 0 ]
	#then
	#	check_system
	#	echo "${GRUPO}"
	#	set_environments_vars
	#	bash test.sh

#		if [ $? -eq 0 ]
#		then
#			check_permissions
#			#set_environments_vars
#		fi
#	fi
}

run
