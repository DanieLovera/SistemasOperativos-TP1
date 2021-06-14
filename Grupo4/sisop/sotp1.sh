#!/bin/bash

# Rutas de todos los archivos default creados.
conf_dir="$(dirname $(realpath $0))"
group_dir="$(dirname $conf_dir)"
original_dir="$group_dir/original"
install_script_path="$conf_dir/sotp1.sh"
install_log_path="$conf_dir/sotp1.log"
conf_file_path="$conf_dir/sotp1.conf"
init_log_path="$conf_dir/soinit.log"
proc_log_path="$conf_dir/tpcuotas.log"
confirmed_directories="$conf_dir/.confirmed_directories"

# Rutas de todos los directorios default.
exe_dir="$group_dir/bin"
sys_tables_dir="$group_dir/master"
news_input_dir="$group_dir/ENTRADATP"
news_input_ok_dir="$group_dir/ENTRADATP/ok"
rejected_files_dir="$group_dir/rechazos"
lots_dir="$group_dir/lotes"
results_dir="$group_dir/SALIDATP"
lib_dir="$group_dir/original/lib"
# include conf_utils
. "$lib_dir/conf_utils.sh"

# include log
. "$lib_dir/log.sh" "$conf_dir/sotp1.log"

# include pprint
. "$lib_dir/pprint.sh"


# Agrega los nombres de directorios principales a un archivo
# oculto con la lista de nombres que el usuario no puede elegir.
function make_confirmed_directories_names() {
	echo "${group_dir##*/}" > "$confirmed_directories"
	log_inf "Creando archivo $confirmed_directories"
	log_inf "Prohibiendo nombre de directorio ${group_dir##*/}"
	echo "sisop" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio sisop"
	echo "original" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio original"
	echo "tp1datos" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio tp1datos"
	echo "misdatos" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio misdatos"
	echo "mispruebas" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio mispruebas"
}

# Remueve el archivo oculto creado para recordar los nombres
# de archivos que el usuario no puede elegir.
function remove_confirmed_directories_names() {
	rm "$confirmed_directories"
	log_inf "Removiendo archivo $confirmed_directories"
}

# @return tmp_dir: se retorna como variable global necesaria para 
# devolver un string.
function ask_for_dir_input() {
	echo -e $(info_message "Defina el nombre del $(bold "$1") o $(bold "enter") para continuar")
	log_inf "Defina el nombre del $1 o enter para continuar"
	echo "... Directorio por defecto: $(underline "$2")"
	log_inf "... Directorio por defecto: $2"
	read -p "... $group_dir/" tmp_dir
	log_inf "... "$tmp_dir""

	if [ -z ""$tmp_dir"" ]
	then
		tmp_dir=$2
	else
		tmp_dir="$group_dir/"$tmp_dir""
	fi
}

# Lee algun directorio de entrada del usuario.
# @param $1: mensaje que se quiere mostrar en pantalla (como contexto
# del directorio).
# @param $2: ruta del directorio de instalacion.
# @return tmp_dir: se retorna como variable global necesaria para 
# devolver un string.
function read_directory() {
	ask_for_dir_input "$1" "$2"

	local found=$(grep "^${tmp_dir##*/}$" $confirmed_directories)
	while [ ! -z "${found}" ] 
	do
		echo  $(warning_message "Nombre invalido, directorio reservado/existente.")
		log_war "Nombre invalido, directorio reservado/existente."
		echo ""

		ask_for_dir_input "$1" "$2"

		found=$(grep "^${tmp_dir##*/}$" $confirmed_directories)
	done

	echo "${tmp_dir##*/}" >> "$confirmed_directories"
	log_inf "Prohibiendo nombre de directorio ${tmp_dir##*/}"

	success_message "Quedó configurado el $(bold "$1") en $(underline ""$tmp_dir"")"
	echo ""
	log_inf "Quedó configurado el $1 en "$tmp_dir""
}

# Crea un directorio
# @param $1: mensaje del directorio creado.
# @param $2: ruta de directorio que se va a crear.
function make_directory() {
	# TODO: en caso de que exista borrarla?
	# rm -r "$2"

	mkdir -p "$2"
	echo -e $(info_message "$(bold "$1") creado en: $(underline "$2")")
	log_inf "$1 creado en: $2"
}

# Crea un archivo
# @param $1: mensaje del archivo creado.
# @param $2: ruta de archivo que se va a crear.
function touch_file() {
	touch "$2"
	info_message "$(bold "$1") creado en: $(underline "$2")"
	log_inf "$1 creado en: $2"
}

# Copia un archivo.
# @param $1: archivo a copiar
# @param $2: destino de archivo a copiar.
function copy_from_to() {
	cp "$1" "$2"
	log_inf "Copiando $1 a $2"
}
# Copia recursivamente de una carpeta a otra
# @param $1: Carpeta origen
# @param $2: Carpeta destino
function copy_rec_from_to() {
	cp -a "$1/." "$2"
	log_inf "Copiando directorio $1 a $2"
}

# Lee la respuesta de confirmacion del usuario
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function read_confirmation_response() {
	local user_response=""
	read -p "¿Confirma la ${1,,}? ($(bold "SI/NO")): " user_response
	log_inf "¿Confirma la ${1,,}? (SI/NO): "
	user_response=$(echo ${user_response} | tr '[:upper:]' '[:lower:]')

	log_inf "Respuesta del usuario ${user_response}"

	if [[ " si s yes y  " =~ " ${user_response} " ]]
	then 
		return 1;
	elif [[ " no n " =~ " ${user_response} " ]]
	then
		return 0;
	else 
		warning_message "Opción inválida, por favor vuelva a intentar."
		log_war "Opción inválida, por favor vuelva a intentar."
		read_confirmation_response "$1"
	fi
}

# Confirma instalacion/reparacion
# @param $1: recibe INSTALACION si la operacion que se realizara
# es de instalacion o REPARACION si es una reparacion.
# @return $?: devuelve un 1 en caso de que la operacion sea confirmada
# o 0 en caso contrario.
function confirm_operation() {
	echo ""
	echo -e "\t $(bold "TP1 SO7508 Cuatrimestre I 2021 Curso Martes Grupo4")"
	log_inf "TP1 SO7508 Cuatrimestre I 2021 Curso Martes Grupo4"
	echo ""
	echo -e "\t Tipo de proceso:                          $(bold "$1")"
	log_inf "Tipo de proceso:                          $1"
	echo -e "\t Directorio padre:                         $(bold "${conf_directories[0]}")"
	log_inf "Directorio padre:                         ${conf_directories[0]}"
	echo -e "\t Ubicación script de instalacion:          $(bold "${install_script_path}")"
	log_inf "Ubicación script de instalacion:          ${install_script_path}"
	echo -e "\t Log de la instalacion:                    $(bold "${install_log_path}")"
	log_inf "Log de la instalacion:                    ${install_log_path}"
	echo -e "\t Archivo de configuracion:                 $(bold "${conf_directories[1]}")"
	log_inf "Archivo de configuracion:                 ${conf_directories[1]}"
	echo -e "\t Log de inicializacion:                    $(bold "${init_log_path}")"
	log_inf "Log de inicializacion:                    ${init_log_path}"
	echo -e "\t Log del proceso principal:                $(bold "${proc_log_path}")"
	log_inf "Log del proceso principal:                ${proc_log_path}"
	echo -e "\t Directorio de ejecutables:                $(bold "${conf_directories[2]}")"
	log_inf "Directorio de ejecutables:                ${conf_directories[2]}"
	echo -e "\t Directorio de tablas maestras:            $(bold "${conf_directories[3]}")"
	log_inf "Directorio de tablas maestras:            ${conf_directories[3]}"
	echo -e "\t Directorio de novedades:                  $(bold "${conf_directories[4]}")"
	log_inf "Directorio de novedades:                  ${conf_directories[4]}"
	echo -e "\t Directorio de novedades aceptadas:        $(bold "${news_input_ok_dir}")"
	log_inf "Directorio de novedades aceptadas:        ${news_input_ok_dir}"
	echo -e "\t Directorio de rechazados:                 $(bold "${conf_directories[5]}")"
	log_inf "Directorio de rechazados:                 ${conf_directories[5]}"
	echo -e "\t Directorio de lotes procesados:           $(bold "${conf_directories[6]}")"
	log_inf "Directorio de lotes procesados:           ${conf_directories[6]}"
	echo -e "\t Directorio de liquidaciones:              $(bold "${conf_directories[7]}")"
	log_inf "Directorio de liquidaciones:              ${conf_directories[7]}"
	echo -e "\t Estado de la ${1,,}:                 $(display_ok "LISTA")"
	log_inf "Estado de la ${1,,}:                 LISTA"

	echo ""

	read_confirmation_response $1
	return $?
}

# Inicializa el archivo de configuracion del sistema.
function make_conf_file() {
	touch_file "Archivo de configuracion" "$conf_file_path"
	echo "GRUPO-${conf_directories[0]}" >> "$conf_file_path"
	log_inf "GRUPO ${conf_directories[0]}"
	echo "DIRCONF-${conf_directories[1]%/*}" >> "$conf_file_path"
	log_inf "DIRCONF ${conf_directories[1]%/*}"
	echo "DIRBIN-${conf_directories[2]}" >> "$conf_file_path"
	log_inf "DIRBIN ${conf_directories[2]}"
	echo "DIRMAE-${conf_directories[3]}" >> "$conf_file_path"
	log_inf "DIRMAE ${conf_directories[3]}"
	echo "DIRENT-${conf_directories[4]}" >> "$conf_file_path"
	log_inf "DIRENT ${conf_directories[4]}"
	echo "DIRRECH-${conf_directories[5]}" >> "$conf_file_path"
	log_inf "DIRRECH ${conf_directories[5]}"
	echo "DIRPROC-${conf_directories[6]}" >> "$conf_file_path"
	log_inf "DIRPROC ${conf_directories[6]}"
	echo "DIRSAL-${conf_directories[7]}" >> "$conf_file_path"
	log_inf "DIRSAL ${conf_directories[7]}"
	echo "INSTALACION-$(date '+%d/%m/%Y %H:%M:%S')-$(whoami)" >> "$conf_file_path"
	log_inf "INSTALACION $(date '+%d/%m/%Y %H:%M:%S') $(whoami)"
}

# Crea los archivos del sistema.
function make_files() {
	#touch_file "Script de instalacion" ${install_script_path}
	#touch_file "Log de la instalacion" ${install_log_path}
	make_conf_file
	touch_file "Log de inicialización" "${init_log_path}"
	touch_file "Log del proceso principal" "${proc_log_path}"
}

# Crea el directorio ejecutables y copia ejecutables del directorio
# original
function make_exe_dir() {
	make_directory "Directorio de ejecutables" "${conf_directories[2]}"
	#copy_rec_from_to "$group_dir/original/bin" "$exe_dir" 
	copy_from_to "${conf_directories[0]}/original/bin/arrancotp1.sh" "${conf_directories[2]}/arrancotp1.sh"
	copy_from_to "${conf_directories[0]}/original/bin/frenotp1.sh" "${conf_directories[2]}/frenotp1.sh"
	copy_from_to "${conf_directories[0]}/original/bin/cuotatp.sh" "${conf_directories[2]}/cuotatp.sh" 
}

# Crea el directorio maestro (del sistema) y copia las tablas maestras
# del directorio original.
function make_sys_tables_dir() {
	make_directory "Directorio de tablas del sistema" "${conf_directories[3]}"
	copy_from_to "$group_dir/original/financiacion.txt" "${conf_directories[3]}"
	copy_from_to "$group_dir/original/terminales.txt" "${conf_directories[3]}"
}

# Crea los directorios del sistema.
function make_directories() {
	make_exe_dir
	make_sys_tables_dir
	make_directory "Directorio de novedades" "${conf_directories[4]}"
	make_directory "Directorio de novedades aceptadas" "${news_input_ok_dir}"
	make_directory "Directorio de archivos rechazados" "${conf_directories[5]}"
	make_directory "Directorio de lotes procesados" "${conf_directories[6]}"
	make_directory "Directorio de resultados" "${conf_directories[7]}"
}

# Construye archivos y directorios del sistema.
function make_all() {
	echo ""
	make_files
	make_directories
}

# Instala el sistema.
function install() {
	make_confirmed_directories_names
	info_message "Comenzando instalacion del sistema..."
	log_inf "Comenzando instalacion del sistema..."
	echo ""

	read_directory "directorio de ejecutables" "${conf_directories[2]}"
	conf_directories[2]="$tmp_dir"
	log_inf "directorio de ejecutables ${conf_directories[2]}"

	read_directory "directorio de tablas del sistema" "${conf_directories[3]}"
	conf_directories[3]="$tmp_dir"
	log_inf "directorio de tablas del sistema ${conf_directories[3]}"

	read_directory "directorio de novedades" "${conf_directories[4]}"
	conf_directories[4]="$tmp_dir"
	log_inf "directorio de novedades ${conf_directories[4]}"
	news_input_ok_dir="$tmp_dir/ok"
	log_inf "directorio de novedades/ok ${news_input_ok_dir}"

	read_directory "directorio de archivos rechazados" "${conf_directories[5]}"
	conf_directories[5]="$tmp_dir"
	log_inf "directorio de archivos rechazados ${conf_directories[5]}"

	read_directory "directorio de lotes procesados" "${conf_directories[6]}"
	conf_directories[6]="$tmp_dir"
	log_inf "directorio de lotes procesados ${conf_directories[6]}"		

	read_directory "directorio de resultados" "${conf_directories[7]}"
	conf_directories[7]="$tmp_dir"	
	log_inf "directorio de resultados ${conf_directories[7]}"		

	confirm_operation "INSTALACION"
	if [ $? -eq 1 ]
	then
		make_all
	else
		info_message "Ha ingresado NO, por favor defina los directorios principales."
		log_inf "Ha ingresado NO, por favor defina los directorios principales."
		install
	fi
}

# Finalizacion del script en caso de que ya este instalado
# y no haya que reparar.
function exit_on_success() {
	info_message "El sistema ya se encuentra instalado."
	log_inf "El sistema ya se encuentra instalado."
	echo ""
	info_message "Archivo de configuración $(bold "$conf_file_path")"
	cat "$conf_file_path" | sed 's/^/\t/'
	cat "$conf_file_path" | while read -r; do log_inf $REPLY; done
}

# Repara el directorio de ejecucion (bin)
function repair_exe() {
	local repaired=1
	if [ ! -d "${conf_directories[2]}" ]
	then
		echo ""
		info_message "Reparando $(underline ${conf_directories[2]})..."
		log_inf "Reparando ${conf_directories[2]}..."
		make_exe_dir
		success_message "Reparado $(underline ${conf_directories[2]})"
		log_inf "Reparado ${conf_directories[2]}"

	else 
		if [ ! -f "${conf_directories[2]}/cuotatp.sh" ]
		then
			echo " "
			info_message "Reparando ${conf_directories[2]}/cuotatp.sh..."
			log_inf "Reparando ${conf_directories[2]}/cuotatp.sh..."
			if [ -f "${conf_directories[0]}/original/bin/cuotatp.sh" ]
			then
				copy_from_to "$original_dir/bin/cuotatp.sh" "${conf_directories[2]}"
				success_message "Reparado ${conf_directories[2]}/cuotatp.sh..."
				log_inf "Reparado ${conf_directories[2]}/cuotatp.sh..."
			else
				error_message "Fallo la reparación de ${conf_directories[2]}/cuotatp.sh"
				log_err "Fallo la reparación de ${conf_directories[2]}/cuotatp.sh"
				error_message "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/cuotatp.sh"
				log_err "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/cuotatp.sh"
				info_message "Para corregir el error se debe descargar el archivo faltante de github"
				log_err "Para corregir el error se debe descargar el archivo faltante de github"
				repaired=0
			fi
		fi

		if [ ! -f "${conf_directories[2]}/arrancotp1.sh" ]
		then
			echo " "
			info_message "Reparando ${conf_directories[2]}/arrancotp1.sh..."
			log_inf "Reparando ${conf_directories[2]}/arrancotp1.sh..."
			if [ -f "${conf_directories[0]}/original/bin/arrancotp1.sh" ]
			then
				copy_from_to "$original_dir/bin/arrancotp1.sh" "${conf_directories[2]}"
				success_message "Reparado ${conf_directories[2]}/arrancotp1.sh..."
				log_inf "Reparado ${conf_directories[2]}/arrancotp1.sh..."
			else
				error_message "Fallo la reparación de ${conf_directories[2]}/arrancotp1.sh"
				log_err "Fallo la reparación de ${conf_directories[2]}/arrancotp1.sh"
				error_message "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/arrancotp1.sh"
				log_err "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/arrancotp1.sh"
				info_message "Para corregir el error se debe descargar el archivo faltante de github"
				log_err "Para corregir el error se debe descargar el archivo faltante de github"
				repaired=0
			fi
		fi

		if [ ! -f "${conf_directories[2]}/frenotp1.sh" ]
		then
			echo " "
			info_message "Reparando ${conf_directories[2]}/frenotp1.sh..."
			log_inf "Reparando ${conf_directories[2]}/frenotp1.sh..."
			if [ -f "${conf_directories[0]}/original/bin/frenotp1.sh" ]
			then
				copy_from_to "$original_dir/bin/frenotp1.sh" "${conf_directories[2]}"
				success_message "Reparado ${conf_directories[2]}/frenotp1.sh..."
				log_inf "Reparado ${conf_directories[2]}/frenotp1.sh..."
			else
				error_message "Fallo la reparación de ${conf_directories[2]}/frenotp1.sh"
				log_err "Fallo la reparación de ${conf_directories[2]}/frenotp1.sh"
				error_message "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/frenotp1.sh"
				log_err "No se pudo encontrar el archivo ${conf_directories[0]}/original/bin/frenotp1.sh"
				info_message "Para corregir el error se debe descargar el archivo faltante de github"
				log_err "Para corregir el error se debe descargar el archivo faltante de github"
				repaired=0
			fi
		fi
	fi
	return ${repaired}
}

# Repara el directorio de tablas del sistema (master)
function repair_sys_table() {
	local repaired=1
	if [ ! -d "${conf_directories[3]}" ]
	then
		echo " "
		info_message "Reparando $(underline ${conf_directories[3]})..."
		log_inf "Reparando ${conf_directories[3]}..."
		if [[ -d "${conf_directories[0]}/original" && \
			  -f "${conf_directories[0]}/original/financiacion.txt" && \
			  -f "${conf_directories[0]}/original/terminales.txt" ]]
		then 
			make_sys_tables_dir
			success_message "Reparado $(underline ${conf_directories[3]})"
			log_inf "Reparado ${conf_directories[3]}"
		else		
			error_message "Fallo la reparación de las tablas maestras"
			log_err "Fallo la reparación de las tablas maestras"
			info_message "Comprobrar la existencia de: "
			log_err "Comprobrar la existencia de: "
			echo -e "\t-${conf_directories[0]}/original"
			log_err "-${conf_directories[0]}/original"
			echo -e "\t-${conf_directories[0]}/original/financiacion.txt"
			log_err "-${conf_directories[0]}/original/financiacion.txt"
			echo -e "\t-${conf_directories[0]}/original/terminales.txt"
			log_err "-${conf_directories[0]}/original/terminales.txt"
			echo "Para corregir el error se deben descargar los archivos faltantes de github"
			log_err "Para corregir el error se deben descargar los archivos faltantes de github"
			repaired=0
		fi
	else
		if [ ! -f "${conf_directories[3]}/financiacion.txt" ]
		then
			echo " "
			info_message "Reparando ${conf_directories[3]}/financiacion.txt..."
			log_inf "Reparando ${conf_directories[3]}/financiacion.txt]..."
			if [ -f "${conf_directories[0]}/original/financiacion.txt" ]
			then
				copy_from_to "$original_dir/financiacion.txt" "${conf_directories[3]}"
				success_message "Reparado ${conf_directories[3]}/financiacion.txt"
				log_inf "Reparado ${conf_directories[3]}/financiacion.txt]"
			else
				error_message "Fallo la reparación de ${conf_directories[3]}/financiacion.txt"
				log_err "Fallo la reparación de ${conf_directories[3]}/financiacion.txt"
				error_message "No se pudo encontrar el archivo ${conf_directories[0]}/original/financiacion.txt"
				log_err "No se pudo encontrar el archivo ${conf_directories[0]}/original/financiacion.txt"
				info_message "Para corregir el error se debe descargar el archivo faltante de github"
				log_err "Para corregir el error se debe descargar el archivo faltante de github"
				repaired=0
			fi
		fi

		if [ ! -f "${conf_directories[3]}/terminales.txt" ]
		then
			echo " "
			info_message "Reparando ${conf_directories[3]}/terminales.txt..."
			log_inf "Reparando ${conf_directories[3]}/terminales.txt]..."
			if [ -f "${conf_directories[0]}/original/terminales.txt" ]
			then
				copy_from_to "$original_dir/terminales.txt" "${conf_directories[3]}"
				success_message "Reparado ${conf_directories[3]}/terminales.txt"
				log_inf "Reparado ${conf_directories[3]}/terminales.txt"
			else
				error_message "Fallo la reparación de ${conf_directories[3]}/terminales.txt"
				log_err "Fallo la reparación de ${conf_directories[3]}/terminales.txt"
				error_message "No se pudo encontrar el archivo ${conf_directories[0]}/original/terminales.txt"
				log_err "No se pudo encontrar el archivo ${conf_directories[0]}/original/terminales.txt"
				info_message "Para corregir el error se debe descargar el archivo faltante de github"
				log_err "Para corregir el error se debe descargar el archivo faltante de github"
				repaired=0
			fi
		fi
	fi
	return ${repaired}
}

# Repara el directorio de nuevas entradas (ENTRADASTP)
function repair_news_input() {
	if [ ! -d "${conf_directories[4]}" ]	
	then
		echo " "
		info_message "Reparando ${conf_directories[4]}..."
		log_inf "Reparando ${conf_directories[4]}..."
		make_directory "Directorio de novedades" "${conf_directories[4]}"
		make_directory "Directorio de novedades aceptadas" "${news_input_ok_dir}"
		success_message "Reparado ${conf_directories[4]}"
		log_inf "Reparado ${conf_directories[4]}"
	else
		if [ ! -d "${news_input_ok_dir}" ]
		then
			echo " "
			info_message "Reparando ${news_input_ok_dir}..."
			log_inf "Reparando ${news_input_ok_dir}..."
			make_directory "Directorio de novedades aceptadas" "${news_input_ok_dir}"
			success_message "Reparado ${news_input_ok_dir}"
			log_inf "Reparado ${news_input_ok_dir}"
		fi
	fi
	return 1
}

# Repara el directorio de rechazados (rechazos)
function repair_rejected() {
	if [ ! -d "${conf_directories[5]}" ]	
	then
		echo " "
		info_message "Reparando ${conf_directories[5]}..."
		log_inf "Reparando ${conf_directories[5]}..."
		make_directory "Directorio de archivos rechazados" "${conf_directories[5]}"
		success_message "Reparado ${conf_directories[5]}"
		log_inf "Reparado ${conf_directories[5]}"
	fi
	return 1
}

# Repara el directorio de lotes
function repair_lots() {
	if [ ! -d "${conf_directories[6]}" ]	
	then
		echo " "
		info_message "Reparando ${conf_directories[6]}..."
		log_inf "Reparando ${conf_directories[6]}..."
		make_directory "Directorio de lotes procesados" "${conf_directories[6]}"
		success_message "Reparado ${conf_directories[6]}"
		log_inf "Reparado ${conf_directories[6]}"
	fi
	return 1
}

# Repara el directorio de resultados (SALIDATP)
function repair_results() {
	if [ ! -d "${conf_directories[7]}" ]	
	then
		echo " "
		info_message "Reparando ${conf_directories[7]}..."
		log_inf "Reparando ${conf_directories[7]}..."
		make_directory "Directorio de resultados" "${conf_directories[7]}"
		success_message "Reparado ${conf_directories[7]}"
		log_inf "Reparado ${conf_directories[7]}"
	fi
	return 1	
}

# Comprueba todas las reparaciones necesarias
function system_check() {
	repair_exe
	if [ $? -eq 1 ]
	then 
		repair_sys_table
	fi
	repair_news_input
	repair_rejected
	repair_lots
	repair_results	
	return $?
}

# Repara el sistema dañado.
function repair() {
	warning_message "Sistema dañado, se procede a rutina de reparación..."
	log_inf "Sistema dañado, se procede a rutina de reparación..."
	confirm_operation "REPARACION"
	
	if [ $? -eq 1 ]
	then
		system_check
		if [ $? -eq 1 ]
		then
			success_message "Estado de la reparación:                     $(display_ok "REPARADO")"
			log_inf "Estado de la reparación:                     REPARADO"	
			sed -i "/^REPARACION/d" "$conf_file_path"
			echo "REPARACION-$(date '+%d/%m/%Y %H:%M:%S')-$(whoami)" >> "$conf_file_path"
			log_inf "REPARACION $(date '+%d/%m/%Y %H:%M:%S') $(whoami)"
		else
			error_message "Estado de la reparación:                     $(bold "FALLIDA")"
			log_err "Estado de la reparación:                     FALLIDA"	
		fi

	else
		error_message "Estado de la reparación:                     $(bold "RECHAZADA")"
		log_err "Estado de la reparación:                     RECHAZADA"
	fi
}

# Ejecuta el script.
function run() {
	if [ ! -f "$conf_file_path" ]
	then
		info_message "Iniciando sistema..."
		log_inf "Iniciando sistema..."

		install
		remove_confirmed_directories_names

		echo ""
		echo "$(success_message "Estado de la instalación:                     $(display_ok "COMPLETADA")")"
		log_inf "Estado de la instalación:                     COMPLETADA"
	else
		check_system

		if [[ $? -ne 0 ]]
		then
			repair
		else
			exit_on_success "$conf_file_path"
		fi
	fi
}

run
