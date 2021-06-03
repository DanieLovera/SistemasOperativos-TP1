#!/bin/bash

#sed -i "s-^INSTALACION-REPARACION-" ./sotp1.conf 

# Rutas de todos los archivos default creados.
group_dir=$(dirname $(pwd))
install_script_path=$(pwd | sed 's-$-/sotp1.sh-')
install_log_path=$(pwd | sed 's-$-/sotp1.log-')
conf_file_path=$(pwd | sed 's-$-/sotp1.conf-')
init_log_path=$(pwd | sed 's-$-/soinit.log-')
proc_log_path=$(pwd | sed 's-$-/tpcuotas.log-')
confirmed_directories=".confirmed_directories"

# Rutas de todos los directorios default.
exe_dir=$(pwd | sed 's-/sisop$-/bin-')
sys_tables_dir=$(pwd | sed 's-/sisop$-/master-')
news_input_dir=$(pwd | sed 's-/sisop$-/ENTRADATP-')
news_input_ok_dir=$(pwd | sed 's-/sisop$-/ENTRADATP/ok-')
rejected_files_dir=$(pwd | sed 's-/sisop$-/rechazos-')
lots_dir=$(pwd | sed 's-/sisop$-/lotes-')
results_dir=$(pwd | sed 's-/sisop$-/SALIDATP-')

# Loggea INF a sotp1.log
# @param $1: mensaje que se adjuntara en el log.
function log_inf() {
	echo "INF-$(date "+%d/%m/%Y %H:%M:%S")-$1-$(whoami)" >> sotp1.log
}

# Loggea WAR a sotp1.log
# @param $1: mensaje que se adjuntara en el log.
function log_war() {
	echo "WAR-$(date "+%d/%m/%Y %H:%M:%S")-$1-$(whoami)" >> sotp1.log
}

# Agrega los nombres de directorios principales a un archivo
# oculto con la lista de nombres que el usuario no puede elegir.
function make_confirmed_directories_names() {
	echo "${group_dir##*/}" > ${confirmed_directories}
	log_inf "Creando archivo ${confirmed_directories}"
	log_inf "Prohibiendo nombre de directorio ${group_dir##*/}"
	echo "sisop" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio sisop"
	echo "original" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio original"
	echo "tp1datos" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio tp1datos"
	echo "misdatos" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio misdatos"
	echo "mispruebas" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio mispruebas"
}

# Remueve el archivo oculto creado para recordar los nombres
# de archivos que el usuario no puede elegir.
function remove_confirmed_directories_names() {
	rm ${confirmed_directories}
	log_inf "Removiendo archivo ${confirmed_directories}"
}

# Lee algun directorio de entrada del usuario.
# @param $1: mensaje que se quiere mostrar en pantalla (como contexto
# del directorio).
# @param $2: ruta del directorio de instalacion.
# @return tmp_dir: se retorna como variable global necesaria para 
# devolver un string.
function read_directory() {
	echo "- Defina el nombre del $1 o presione enter para"
	log_inf "Defina el nombre del $1 o presione enter para"
	read -p "continuar [directorio por defecto $2]: " tmp_dir
	log_inf "continuar [directorio por defecto $2]: ${tmp_dir}"

	if [ -z ${tmp_dir} ]
	then
		tmp_dir=$2
	fi

	local found=$(grep "^${tmp_dir##*/}$" ${confirmed_directories})
	while [ ! -z ${found} ] 
	do
		echo -e "\nNombre invalido, directorio reservado/existente."
		log_war "Nombre invalido, directorio reservado/existente."
		echo "- Defina el nombre del $1 o presione enter para"
		log_war "Defina el nombre del $1 o presione enter para"
		read -p "continuar [directorio por defecto $2]: " tmp_dir
		log_war "continuar [directorio por defecto $2]: ${tmp_dir}"

		if [ -z ${tmp_dir} ]
		then
			tmp_dir=$2
		fi

		found=$(grep "^${tmp_dir##*/}$" ${confirmed_directories})
	done

	echo "${tmp_dir##*/}" >> ${confirmed_directories}
	log_inf "Prohibiendo nombre de directorio ${tmp_dir##*/}"

	mkdir ${tmp_dir}
	tmp_dir=$(find "$(cd ../..; pwd)" -type d -name ${tmp_dir##*/})
	rm -r ${tmp_dir}
}

# Crea un directorio
# @param $1: mensaje del directorio creado.
# @param $2: ruta de directorio que se va a crear.
function make_directory() {
	mkdir $2
	echo -e "$1 creado en: $2"
	log_inf "$1 creado en: $2"
}

# Crea un archivo
# @param $1: mensaje del archivo creado.
# @param $2: ruta de archivo que se va a crear.
function touch_file() {
	touch $2
	echo -e "$1 creado en: $2"
	log_inf "$1 creado en: $2"
}

# Confirma instalacion/reparacion
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function confirm_operation() {
	echo " "
	echo "TP1 SO7508 Cuatrimestre I 2021 Curso Martes Grupo4"
	log_inf "TP1 SO7508 Cuatrimestre I 2021 Curso Martes Grupo4"
	echo "Tipo de proceso:                          $1"
	log_inf "Tipo de proceso:                          $1"
	echo "Directorio padre:                         ${group_dir}"
	log_inf "Directorio padre:                         ${group_dir}"
	echo "Ubicación script de instalacion:          ${install_script_path}"
	log_inf "Ubicación script de instalacion:          ${install_script_path}"
	echo "Log de la instalacion:                    ${install_log_path}"
	log_inf "Log de la instalacion:                    ${install_log_path}"
	echo "Archivo de configuracion:                 ${conf_file_path}"
	log_inf "Archivo de configuracion:                 ${conf_file_path}"
	echo "Log de inicializacion:                    ${init_log_path}"
	log_inf "Log de inicializacion:                    ${init_log_path}"
	echo "Log del proceso principal:                ${proc_log_path}"
	log_inf "Log del proceso principal:                ${proc_log_path}"
	echo "Directorio de ejecutables:                ${exe_dir}"
	log_inf "Directorio de ejecutables:                ${exe_dir}"
	echo "Directorio de tablas maestras:            ${sys_tables_dir}"
	log_inf "Directorio de tablas maestras:            ${sys_tables_dir}"
	echo "Directorio de novedades:                  ${news_input_dir}"
	log_inf "Directorio de novedades:                  ${news_input_dir}"
	echo "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	log_inf "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	echo "Directorio de rechazados:                 ${rejected_files_dir}"
	log_inf "Directorio de rechazados:                 ${rejected_files_dir}"
	echo "Directorio de lotes procesados:           ${lots_dir}"
	log_inf "Directorio de lotes procesados:           ${lots_dir}"
	echo "Directorio de liquidaciones:              ${results_dir}"
	log_inf "Directorio de liquidaciones:              ${results_dir}"
	echo "Estado de la instalacion:                 LISTA"
	log_inf "Estado de la instalacion:                 LISTA"
	read_confirmation_response $1
	return $?
}

# Lee la respuesta de confirmacion del usuario
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function read_confirmation_response() {
	local user_response=""
	read -p "¿Confirma la $(echo $1 | tr '[:upper:]' '[:lower:]')? (SI/NO): " user_response
	log_inf "¿Confirma la $1? (SI/NO): "
	user_response=$(echo ${user_response} | tr '[:upper:]' '[:lower:]')
	log_inf "${user_response}"
	if [ ${user_response} = "si" ]
	then 
		return 1;
	elif [ ${user_response} = "no" ]
	then
		return 0;
	else 
		echo "Opcion invalida, por favor vuelva a intentar."
		log_war "Opcion invalida, por favor vuelva a intentar."
		read_confirmation_response
	fi
}

# Inicializa el archivo de configuracion del sistema.
function make_conf_file() {
	touch_file "Archivo de configuracion" ${conf_file_path}
	echo "GRUPO-${group_dir}" >> ${conf_file_path}
	log_inf "GRUPO ${group_dir}"
	echo "DIRCONF-${conf_file_path%/*}" >> ${conf_file_path}
	log_inf "DIRCONF ${conf_file_path%/*}"
	echo "DIRBIN-${exe_dir}" >> ${conf_file_path}
	log_inf "DIRBIN ${exe_dir}"
	echo "DIRMAE-${sys_tables_dir}" >> ${conf_file_path}
	log_inf "DIRMAE ${sys_tables_dir}"
	echo "DIRENT-${news_input_dir}" >> ${conf_file_path}
	log_inf "DIRENT ${news_input_dir}"
	echo "DIRRECH-${rejected_files_dir}" >> ${conf_file_path}
	log_inf "DIRRECH ${rejected_files_dir}"
	echo "DIRPROC-${lots_dir}" >> ${conf_file_path}
	log_inf "DIRPROC ${lots_dir}"
	echo "DIRSAL-${results_dir}" >> ${conf_file_path}
	log_inf "DIRSAL ${results_dir}"
	echo "INSTALACION-$(date '+%d/%m/%Y %H:%M:%S')-$(whoami)" >> ${conf_file_path}
	log_inf "INSTALACION $(date '+%d/%m/%Y %H:%M:%S') $(whoami)"
}

# Crea los archivos del sistema.
function make_files() {
	#touch_file "Script de instalacion" ${install_script_path}
	#touch_file "Log de la instalacion" ${install_log_path}
	make_conf_file
	touch_file "Log de inicializacion" ${init_log_path}
	touch_file "Log del proceso principal" ${proc_log_path}
}

# Crea los directorios del sistema.
function make_directories() {
	make_directory "Directorio de ejecutables" ${exe_dir}
	make_directory "Directorio de tablas del sistema" ${sys_tables_dir}
	make_directory "Directorio de novedades" ${news_input_dir}
	make_directory "Directorio de novedades aceptadas" ${news_input_ok_dir}
	make_directory "Directorio de archivos rechazados" ${rejected_files_dir}
	make_directory "Directorio de lotes procesados" ${lots_dir}
	make_directory "Directorio de resultados" ${results_dir}	
}

# Construye archivos y directorios del sistema.
function make_all() {
	echo " "
	make_files
	make_directories
}

# Instala el sistema haciendo uso de las demas funciones.
function install() {
	make_confirmed_directories_names

	if [ ! -f ${conf_file_path} ] # Condicion a ejecutar si no se encuentra el arch de configuracion.
	then
		echo -e "Comenzando instalacion del sistema...\n"
		log_inf "Comenzando instalacion del sistema..."
		
		read_directory "directorio de ejecutables" ${exe_dir}
		exe_dir=${tmp_dir}
		log_inf "directorio de ejecutables ${exe_dir}"

		read_directory "directorio de tablas del sistema" ${sys_tables_dir}
		sys_tables_dir=${tmp_dir}
		log_inf "directorio de tablas del sistema ${sys_tables_dir}"

		read_directory "directorio de novedades" ${news_input_dir}
		news_input_dir=${tmp_dir}
		log_inf "directorio de novedades ${news_input_dir}"
		news_input_ok_dir=$(echo ${tmp_dir}/ok)
		log_inf "directorio de novedades/ok ${news_input_ok_dir}"

		read_directory "directorio de archivos rechazados" ${rejected_files_dir}
		rejected_files_dir=${tmp_dir}
		log_inf "directorio de archivos rechazados ${rejected_files_dir}"

		read_directory "directorio de lotes procesados" ${lots_dir}
		lots_dir=${tmp_dir}
		log_inf "directorio de lotes procesados ${lots_dir}"		

		read_directory "directorio de resultados" ${results_dir}
		results_dir=${tmp_dir}
		log_inf "directorio de resultados ${results_dir}"		

		confirm_operation "INSTALACION"
		if [ $? -eq 1 ]
		then
			make_all
		else
			echo "Ha ingresado NO, por favor defina los directorios principales."
			log_inf "Ha ingresado NO, por favor defina los directorios principales."
			install
		fi
	else
		echo "El sistema ya se encuentra instalado."
		log_inf "El sistema ya se encuentra instalado."
	fi
	remove_confirmed_directories_names
}

echo "Iniciando sistema..."
log_inf "Iniciando sistema..."
install
