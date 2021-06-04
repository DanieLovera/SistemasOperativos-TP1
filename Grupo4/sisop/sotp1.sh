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

conf_directories=("$group_dir" "$conf_file_path" "$exe_dir" "$sys_tables_dir" "$news_input_dir" "$rejected_files_dir" "$lots_dir" "$results_dir")

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

# Copia un archivo.
# @param $1: archivo a copiar
# @param $2: destino de archivo a copiar.
function copy_from_to() {
	cp $1 $2
	log_inf "Copiando $1 a $2"
}

# Lee la respuesta de confirmacion del usuario
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function read_confirmation_response() {
	local user_response=""
	read -p "¿Confirma la $(echo $1 | tr '[:upper:]' '[:lower:]')? (SI/NO): " user_response
	log_inf "¿Confirma la $(echo $1 | tr '[:upper:]' '[:lower:]')? (SI/NO): "
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
	echo "Directorio padre:                         ${conf_directories[0]}"
	log_inf "Directorio padre:                         ${conf_directories[0]}"
	echo "Ubicación script de instalacion:          ${install_script_path}"
	log_inf "Ubicación script de instalacion:          ${install_script_path}"
	echo "Log de la instalacion:                    ${install_log_path}"
	log_inf "Log de la instalacion:                    ${install_log_path}"
	echo "Archivo de configuracion:                 ${conf_directories[1]}"
	log_inf "Archivo de configuracion:                 ${conf_directories[1]}"
	echo "Log de inicializacion:                    ${init_log_path}"
	log_inf "Log de inicializacion:                    ${init_log_path}"
	echo "Log del proceso principal:                ${proc_log_path}"
	log_inf "Log del proceso principal:                ${proc_log_path}"
	echo "Directorio de ejecutables:                ${conf_directories[2]}"
	log_inf "Directorio de ejecutables:                ${conf_directories[2]}"
	echo "Directorio de tablas maestras:            ${conf_directories[3]}"
	log_inf "Directorio de tablas maestras:            ${conf_directories[3]}"
	echo "Directorio de novedades:                  ${conf_directories[4]}"
	log_inf "Directorio de novedades:                  ${conf_directories[4]}"
	echo "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	log_inf "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	echo "Directorio de rechazados:                 ${conf_directories[5]}"
	log_inf "Directorio de rechazados:                 ${conf_directories[5]}"
	echo "Directorio de lotes procesados:           ${conf_directories[6]}"
	log_inf "Directorio de lotes procesados:           ${conf_directories[6]}"
	echo "Directorio de liquidaciones:              ${conf_directories[7]}"
	log_inf "Directorio de liquidaciones:              ${conf_directories[7]}"
	echo "Estado de la $(echo $1 | tr '[:upper:]' '[:lower:]'):                 LISTA"
	log_inf "Estado de la $(echo $1 | tr '[:upper:]' '[:lower:]'):                 LISTA"
	read_confirmation_response $1
	return $?
}

# Inicializa el archivo de configuracion del sistema.
function make_conf_file() {
	touch_file "Archivo de configuracion" ${conf_file_path}
	echo "GRUPO-${conf_directories[0]}" >> ${conf_file_path}
	log_inf "GRUPO ${conf_directories[0]}"
	echo "DIRCONF-${conf_directories[1]%/*}" >> ${conf_file_path}
	log_inf "DIRCONF ${conf_directories[1]%/*}"
	echo "DIRBIN-${conf_directories[2]}" >> ${conf_file_path}
	log_inf "DIRBIN ${conf_directories[2]}"
	echo "DIRMAE-${conf_directories[3]}" >> ${conf_file_path}
	log_inf "DIRMAE ${conf_directories[3]}"
	echo "DIRENT-${conf_directories[4]}" >> ${conf_file_path}
	log_inf "DIRENT ${conf_directories[4]}"
	echo "DIRRECH-${conf_directories[5]}" >> ${conf_file_path}
	log_inf "DIRRECH ${conf_directories[5]}"
	echo "DIRPROC-${conf_directories[6]}" >> ${conf_file_path}
	log_inf "DIRPROC ${conf_directories[6]}"
	echo "DIRSAL-${conf_directories[7]}" >> ${conf_file_path}
	log_inf "DIRSAL ${conf_directories[7]}"
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

function make_exe_dir() {
	make_directory "Directorio de ejecutables" ${conf_directories[2]}
	# COPIAR ACA LOS EJECUTABLES CUANDO ESTEN DEL PASO 5.
}

function make_sys_tables_dir() {
	make_directory "Directorio de tablas del sistema" ${conf_directories[3]}
	copy_from_to "../original/financiacion.txt" "${conf_directories[3]}"
	copy_from_to "../original/terminales.txt" "${conf_directories[3]}"
}

# Crea los directorios del sistema.
function make_directories() {
	make_exe_dir
	make_sys_tables_dir
	make_directory "Directorio de novedades" ${conf_directories[4]}
	make_directory "Directorio de novedades aceptadas" "${news_input_ok_dir}"
	make_directory "Directorio de archivos rechazados" ${conf_directories[5]}
	make_directory "Directorio de lotes procesados" ${conf_directories[6]}
	make_directory "Directorio de resultados" ${conf_directories[7]}	
}

# Construye archivos y directorios del sistema.
function make_all() {
	echo " "
	make_files
	make_directories
}

# Instala el sistema.
function install() {
	make_confirmed_directories_names
	echo -e "Comenzando instalacion del sistema...\n"
	log_inf "Comenzando instalacion del sistema..."
	
	read_directory "directorio de ejecutables" ${conf_directories[2]}
	conf_directories[2]=${tmp_dir}
	log_inf "directorio de ejecutables ${conf_directories[2]}"

	read_directory "directorio de tablas del sistema" ${conf_directories[3]}
	conf_directories[3]=${tmp_dir}
	log_inf "directorio de tablas del sistema ${conf_directories[3]}"

	read_directory "directorio de novedades" ${conf_directories[4]}
	conf_directories[4]=${tmp_dir}
	log_inf "directorio de novedades ${conf_directories[4]}"
	news_input_ok_dir="${tmp_dir}/ok"
	log_inf "directorio de novedades/ok ${news_input_ok_dir}"

	read_directory "directorio de archivos rechazados" ${conf_directories[5]}
	conf_directories[5]=${tmp_dir}
	log_inf "directorio de archivos rechazados ${conf_directories[5]}"

	read_directory "directorio de lotes procesados" ${conf_directories[6]}
	conf_directories[6]=${tmp_dir}
	log_inf "directorio de lotes procesados ${conf_directories[6]}"		

	read_directory "directorio de resultados" ${conf_directories[7]}
	conf_directories[7]=${tmp_dir}	
	log_inf "directorio de resultados ${conf_directories[7]}"		

	confirm_operation "INSTALACION"
	if [ $? -eq 1 ]
	then
		make_all
	else
		echo "Ha ingresado NO, por favor defina los directorios principales."
		log_inf "Ha ingresado NO, por favor defina los directorios principales."
		install
	fi
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
    	if [ ! -d "${directory}" ] 
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
	if [[ ! -f "${conf_directories[3]}/financiacion.txt" || \
		  !	-f "${conf_directories[3]}/terminales.txt" ]]
	then
		return 1
	fi
	return 0
}

# Finalizacion del script en caso de que ya este instalado
# y no haya que reparar.
function exit() {
	echo "El sistema ya se encuentra instalado."
	log_inf "El sistema ya se encuentra instalado."
	local backIFS=$IFS
	while IFS='' read -r line || [[ -n "${line}" ]]
	do
		echo "${line}"
		log_inf "${line}"
	done < ${conf_file_path}
	IFS=$backIFS
}

# Repara el sistema dañado.
function repair() {
	echo "Sistema dañado, se procede a rutina de reparacion..."
	log_inf "Sistema dañado, se procede a rutina de reparacion..."
	confirm_operation "REPARACION"
	
	if [ $? -eq 1 ]
	then
		#make_all
		echo "Cualquiera"
	else
		echo "Estado de la reparacion:                     RECHAZADA"
		log_inf "Estado de la reparacion:                     RECHAZADA"
	fi
}

# Ejecuta el script.
function run() {
	if [ ! -f ${conf_file_path} ] # Condicion a ejecutar si no se encuentra el arch de configuracion.
	then
		echo "Iniciando sistema..."
		log_inf "Iniciando sistema..."
		install
		remove_confirmed_directories_names
		echo "Estado de la instalación:                     COMPLETADA"
		log_inf "Estado de la instalación:                     COMPLETADA"
	else
		load_conf_directories ${conf_file_path}
		is_missing_directory
		local missing_directory_status=$?
		is_missing_file
		local missing_file_status=$?

		if [[ ${missing_directory_status} -eq 0 && ${missing_file_status} -eq 0 ]]
		then
			exit ${conf_file_path}
		else
			repair
		fi
	fi
}

run
