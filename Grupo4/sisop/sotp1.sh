#!/bin/bash

conf_file_path="./sotp1.conf"
exe_dir=$(pwd | sed 's-/sisop$-/bin-')
sys_tables_dir=$(pwd | sed 's-/sisop$-/master-')
news_input_dir=$(pwd | sed 's-/sisop$-/ENTRADATP-')
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
# del directorio)
# @param $2: ruta del directorio por defecto
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

# Crea el directorio de ejecucion
# @param $1: mensaje del directorio creado.
# @param $2: ruta de archivo que se va a crear.
function make_directory() {
	mkdir $2
	echo -e "$1 creado en: $2"
}

# Instala el sistema haciendo uso de las demas funciones.
function install() {
	echo "Iniciando sistema..."
	
	if [ ! -f ${conf_file_path} ]
	then
		echo -e "Comenzando instalacion del sistema...\n"
		
		read_directory "directorio de ejecutables" ${exe_dir}
		exe_dir=${tmp_dir}
		read_directory "directorio de tablas del sistema" ${sys_tables_dir}
		sys_tables_dir=${tmp_dir}
		read_directory "directorio de novedades" ${news_input_dir}
		news_input_dir=${tmp_dir}
		read_directory "directorio de archivos rechazados" ${rejected_files_dir}
		rejected_files_dir=${tmp_dir}
		read_directory "directorio de lotes procesados" ${lots_dir}
		lots_dir=${tmp_dir}
		read_directory "directorio de resultados" ${results_dir}
		results_dir=${tmp_dir}

		#echo "Creando archivo de configuracion ${conf_file_path#./}..."
		##touch ${conf_file_path}
		#echo "${conf_file_path#./} correctamente instalado."
		echo " "
		make_directory "Directorio de ejecutables" ${exe_dir}
		make_directory "Directorio de tablas del sistema" ${sys_tables_dir}
		make_directory "Directorio de novedades" ${news_input_dir}
		make_directory "Directorio de archivos rechazados" ${rejected_files_dir}
		make_directory "Directorio de lotes procesados" ${lots_dir}
		make_directory "Directorio de resultados" ${results_dir}
	else
		echo "El sistema ya se encuentra instalado."
	fi
}

install
