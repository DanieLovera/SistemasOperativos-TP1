#!/bin/bash

# #PARA FEDEBUR
path_to_log="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/sisop/tpcuotas.log"
path_to_entry="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP"
path_to_lote="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/lotes"
path_to_rechazos="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/rechazos"
path_to_ok="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP/ok"
path_to_sal="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/SALIDATP"
path_to_terminales="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/original/terminales.txt"

# #PARA MANULON
# path_to_log="/home/manulon/Escritorio/TP1-SISOP/Grupo4/sisop/tpcuotas.log"
# path_to_entry="/home/manulon/Escritorio/TP1-SISOP/Grupo4/ENTRADATP"
# path_to_lote="/home/manulon/Escritorio/TP1-SISOP/Grupo4/lotes"
# path_to_rechazos="/home/manulon/Escritorio/TP1-SISOP/Grupo4/rechazos"
# path_to_ok="/home/manulon/Escritorio/TP1-SISOP/Grupo4/ENTRADATP/ok"
# path_to_sal="/home/manulon/Escritorio/TP1-SISOP/Grupo4/SALIDATP"
# path_to_terminales="/home/manulon/Escritorio/TP1-SISOP/Grupo4/master/terminales.txt"

cycle=1


function log_inf() {
    echo "INF-$(date "+%d/%m/%Y %H:%M:%S")-$1-$(whoami)" >> ${path_to_log}
}

function log_war() {
	echo "WAR-$(date "+%d/%m/%Y %H:%M:%S")-$1-$(whoami)" >> ${path_to_log}
}
function log_err() {
    echo ${1}
	echo "ERR-$(date "+%d/%m/%Y %H:%M:%S")-${1}-$(whoami)" >> ${path_to_log}
}
function reject_field() {
    local rejected_transactions=${path_to_rechazos}/${comercio}/transacciones.rech
    echo "Se rechazo porque $1 desde el archivo $2 el registro: " >> ${rejected_transactions}
    echo "$3" >> ${rejected_transactions} 
}
function duplicate() {
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		if [ ! -f  ${path_to_lote}/${line} ]
        then
            echo ${line}
        else
            mv "${path_to_entry}/${line}" "${path_to_rechazos}"
            log_inf "${line} se rechazo por estar vacio"
        fi
	done
}
function filter_lote() {
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
        local var=$(echo ${line} | grep "^Lote[0-9]\{5\}_[0-9]\{2\}$")
		if [ -z ${var} ]
        then
            mv "${path_to_entry}/${line}" "${path_to_rechazos}" 
            log_inf "${line} se rechazo por nombre no valido"
        else
            echo ${line}
        fi
	done
}
function filter_empty() {
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		if [ ! -s ${line} ] 
        then
            echo ${line}
        else 
            mv "${path_to_entry}/${line}" "${path_to_rechazos}" 
            log_inf "${line} se rechazo por estar vacio"
        fi
	done
}
function move_to_ok() {
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		# mv ${path_to_entry}/${line} ${path_to_entry}/ok
        # log_inf "${line} guardado en ok"
        echo ${line}
	done
}
function filter_files() {
    ls ${path_to_entry} -I 'ok' | filter_lote | duplicate | filter_empty
    # falta chequear que sea de texto 
}
function process_files() {
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		echo ${line} | process_file

	done
}
function process_file() {
    read -r file_name
    # echo ${line} | filter_bad_file
    local comercio=$(echo ${file_name} | cut -c 5-9) #substring
    mkdir -p ${path_to_rechazos}/${comercio}
    grep "^" ${path_to_entry}/${file_name} | process_registers
    echo "a,sdfhjs" >> ${path_to_sal}/${comercio}.txt
function log_missing_registers() {
    msg="En el archivo ${file_name} faltan los registros "
    while [ ${idx} -lt ${index} ]
    do
        msg="${msg}${idx} "
        idx=$((${idx}+1))
    done
    echo "ERR-$(date "+%d/%m/%Y %H:%M:%S")-${msg}-$(whoami)" >> ${path_to_log}
}
function process_registers() {
    idx=1
    idx=$((10#${idx}))
    while  read -r register || [[ -n "${register}" ]]
    do
        local fields=$(echo "${register}" |  grep -o "," | wc -l)
        if [ ! ${fields} -eq 13 ]; then
            reject_field "cantidad de campos incorrecta" ${file_name} ${register}
        fi
        index=$(echo "${register}" | cut -d "," -f1)
        index=$((10#${index}))

        if [ ${idx} -gt ${index} ] ; then
            reject_field "la secuencia es menor a la esperada" ${file_name} ${register}
        fi

        if [ ${index} -gt ${idx} ] ; then
            log_missing_registers
            idx=$((${index}))
        fi

        comercio_code=$(echo "${register}" | cut -d "," -f2 | cut -c 2-6)

        if [ ! ${comercio_code} -eq ${comercio} ] ; then
            reject_field "no coincide el numero de comercio con el nombre del archivo"\ 
            ${file_name} ${register}           
        fi

        x=$(echo "${register}" | cut -d "," -f2)
        y=$(echo "${register}" | cut -d "," -f3)
        z="${x},${y}"

        terminales_line_found=$(grep ${z} ${path_to_terminales})

        if [[ "${z}" != "${terminales_line_found}" ]] ; then
            reject_field "no existe en la tabla maestra terminales.txt" ${file_name} ${register}           
        fi

        idx=$((${idx}+1))
    done
}
function filter_bad_file() {
    read file_name
    var=$(grep -c "^[^0-9]\{4\}" ${path_to_entry}/${file_name}) 
    if [ ${var} != 0 ] ;then
        mv "${path_to_entry}/${file_name}" "${path_to_rechazos}" 
        log_inf "${line} se rechazo por tener indice no numerico"
        return 1 #no sigue procesando
    fi
    echo ${file_name}
    grep "^[0-9]\{4\}" ${path_to_entry}/${file_name} |  check_increment
    grep "^" ${path_to_entry}/${file_name} | check_fields 
}

function check_increment() {
    idx=1
    while  read -r line || [[ -n "${line}" ]]
    do
        local var=$(echo ${line} | grep -o "^[0-9]\{4\}")
        var=$((10#${var})) # casteo a base 10
        if [ ${var} -lt ${idx} ] ;then
            mv "${path_to_entry}/${file_name}" "${path_to_rechazos}" 
            log_inf "${file_name} se rechazo por tener indice mal ordenado o faltante"
            return
        fi
        idx=$((${idx}+1))
    done

}

# local var=$(echo ${line} | grep '^[0-9]\{4\}')
# if [ -z ${var} ]; then
#     mv "${path_to_entry}/${line}" "${path_to_rechazos}" 
#     log_inf "${line} se rechazo por formato no esperado"
#     break
# fi


# log_inf "voy por el ciclo ${cycle}"
# cycle=$((${cycle}+1))
# log_inf "voy por el ciclo ${cycle}"
filter_files | process_files