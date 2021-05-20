#!/bin/bash

conf_file_path="./sotp1.conf"
dir_exe="../bin"


# Lee el directorio de entrada.
# El directorio ingresado por el usuario debe encontrarse en la ruta
# $(GRUPO4)/, las verificaciones de existencias de archivos se realizan
# sobre el directorio padre de $(GRUPO4) para validar la no inclusion
# del mismo archivo Grupo4. Por lo tanto como hipotesis, no se pueden
# definir rutas de archivos como nombres que esten fuera de $(GRUPO4)/
function read_exe_directory() {
	echo "- Defina el nombre del directorio de ejecutables o presione enter para"
	read -p "  continuar [directorio por defecto ${dir_exe}]: " dir_exe_tmp

	if [ -z ${dir_exe_tmp} ]
	then
		dir_exe_tmp=${dir_exe}
	fi

	local found=$(find ../.. -type d -name ${dir_exe_tmp##*/})
	while [ ! -z ${found} ] 
	do
		echo -e "\nNombre invalido, el directorio ya existe."
		echo "- Defina el nombre del directorio de ejecutables o presione enter para"
		read -p "  continuar [directorio por defecto ${dir_exe}]: " dir_exe_tmp

		if [ -z ${dir_exe_tmp} ]
		then
			dir_exe_tmp=${dir_exe}
		fi

		found=$(find ../.. -type d -name ${dir_exe_tmp##*/})
	done

	mkdir ${dir_exe_tmp}
	dir_exe=$(find "$(cd ../..; pwd)" -type d -name ${dir_exe_tmp##*/})
	rm -r ${dir_exe_tmp}
}

# Crea el directorio de ejecucion
function make_exe_directory() {
	mkdir $1
	echo -e "\nDirectorio de ejecutables creado en: $1"
}

# Instala el sistema haciendo uso de las demas funciones.
function install() {
	echo "Iniciando sistema..."
	
	if [ ! -f ${conf_file_path} ]
	then
		echo -e "Comenzando instalacion del sistema...\n"
		read_exe_directory

		#echo "Creando archivo de configuracion ${conf_file_path#./}..."
		##touch ${conf_file_path}
		#echo "${conf_file_path#./} correctamente instalado."
		make_exe_directory ${dir_exe}
	else
		echo "El sistema ya se encuentra instalado."
	fi
}

install
