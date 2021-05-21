#!/bin/bash

# Rutas de todos los archivos y directorios creados.
group_dir=$(dirname $(pwd))
install_script_path=$(pwd | sed 's-$-/sotp1.sh-')
install_log_path=$(pwd | sed 's-$-/sotp1.log-')
conf_file_path=$(pwd | sed 's-$-/sotp1.conf-')
init_log_path=$(pwd | sed 's-$-/soinit.log-')
proc_log_path=$(pwd | sed 's-$-/tpcuotas.log-')
exe_dir=$(pwd | sed 's-/sisop$-/bin-')
sys_tables_dir=$(pwd | sed 's-/sisop$-/master-')
news_input_dir=$(pwd | sed 's-/sisop$-/ENTRADATP-')
news_input_ok_dir=$(pwd | sed 's-/sisop$-/ENTRADATP/ok-')
rejected_files_dir=$(pwd | sed 's-/sisop$-/rechazos-')
lots_dir=$(pwd | sed 's-/sisop$-/lotes-')
results_dir=$(pwd | sed 's-/sisop$-/SALIDATP-')

# Lee algun directorio de entrada del usuario.
# El directorio ingresado por el usuario debe encontrarse en la ruta
# $(GRUPO4)/, las verificaciones de existencias de archivos se realizan
# sobre el directorio padre de $(GRUPO4) para validar la no inclusion
# del mismo archivo Grupo4. Por lo tanto como hipotesis, no se pueden
# definir rutas de archivos como nombres que esten fuera de $(GRUPO4)/
# @param $1: mensaje que se quiere mostrar en pantalla (como contexto
# del directorio).
# @param $2: ruta del directorio de instalacion.
# @return tmp_dir: se retorna como variable global necesaria para 
# devolver un string.
function read_directory() {
	echo "- Defina el nombre del $1 o presione enter para"
	read -p "  continuar [directorio por defecto $2]: " tmp_dir

	if [ -z ${tmp_dir} ]
	then
		tmp_dir=$2
	fi

	local found=$(find ../.. -type d -name ${tmp_dir##*/})
	while [ ! -z ${found} ] 
	do
		echo -e "\nNombre invalido, el directorio ya existe."
		echo "- Defina el nombre del $1 o presione enter para"
		read -p "  continuar [directorio por defecto $2]: " tmp_dir

		if [ -z ${tmp_dir} ]
		then
			tmp_dir=$2
		fi

		found=$(find ../.. -type d -name ${tmp_dir##*/})
	done

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
}

# Crea un archivo
# @param $1: mensaje del archivo creado.
# @param $2: ruta de archivo que se va a crear.
function touch_file() {
	touch $2
	echo -e "$1 creado en: $2"
}

# Confirma instalacion/reparacion
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function confirm_operation() {
	echo " "
	echo "TP1 SO7508 Cuatrimestre I 2021 Curso Martes Grupo4"
	echo "Tipo de proceso:                          $1"
	echo "Directorio padre:                         ${group_dir}"
	echo "Ubicación script de instalacion:          ${install_script_path}"
	echo "Log de la instalacion:                    ${install_log_path}"
	echo "Archivo de configuracion:                 ${conf_file_path}"
	echo "Log de inicializacion:                    ${init_log_path}"
	echo "Log del proceso principal:                ${proc_log_path}"
	echo "Directorio de ejecutables:                ${exe_dir}"
	echo "Directorio de tablas maestras:            ${sys_tables_dir}"
	echo "Directorio de novedades:                  ${news_input_dir}"
	echo "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	echo "Directorio de rechazados:                 ${rejected_files_dir}"
	echo "Directorio de lotes procesados:           ${lots_dir}"
	echo "Directorio de liquidaciones:              ${results_dir}"
	echo "Estado de la instalacion:                 LISTA"
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
	user_response=$(echo ${user_response} | tr '[:upper:]' '[:lower:]')
	if [ ${user_response} = "si" ]
	then 
		return 1;
	elif [ ${user_response} = "no" ]
	then
		return 0;
	else 
		echo "Opcion invalida, por favor vuelva a intentar."
		read_confirmation_response
	fi
}

# Crea los archivos del sistema.
function touch_files() {
	touch_file "Script de instalacion" ${install_script_path}
	touch_file "Log de la instalacion" ${install_log_path}
	touch_file "Archivo de configuracion" ${conf_file_path}
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

function make_all() {
	echo " "
	touch_files
	make_directories
}


# Instala el sistema haciendo uso de las demas funciones.
function install() {
	if [ ! -f ${conf_file_path} ]
	then
		echo -e "Comenzando instalacion del sistema...\n"
		
		read_directory "directorio de ejecutables" ${exe_dir}
		exe_dir=${tmp_dir}
		read_directory "directorio de tablas del sistema" ${sys_tables_dir}
		sys_tables_dir=${tmp_dir}
		read_directory "directorio de novedades" ${news_input_dir}
		news_input_dir=${tmp_dir}
		news_input_ok_dir=$(echo ${tmp_dir}/ok)
		read_directory "directorio de archivos rechazados" ${rejected_files_dir}
		rejected_files_dir=${tmp_dir}
		read_directory "directorio de lotes procesados" ${lots_dir}
		lots_dir=${tmp_dir}
		read_directory "directorio de resultados" ${results_dir}
		results_dir=${tmp_dir}

		confirm_operation "INSTALACION"
		if [ $? -eq 1 ]
		then
			make_all
		else
			echo "Ha ingresado NO, por favor defina los directorios principales."
			install
		fi
	else
		echo "El sistema ya se encuentra instalado."
	fi
}

echo "Iniciando sistema..."
install
