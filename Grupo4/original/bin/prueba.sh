#!/bin/bash

# var=$(grep -c "^[0-9]\{4\}" /home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/lotes/Lote10102_01) 
# if [  ${var} == 0 ] ;then
#     echo "vale 0" 
# fi 
# grep -c "^[^0-9]\{4\}" /home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/lotes/Lote10102_01
path_to_log="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/sisop/tpcuotas.log"
path_to_entry="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP"
path_to_lote="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/lotes"
path_to_rechazos="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/rechazos"
path_to_ok="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP/ok"

function reject_field() {
    local rejected_transactions=${path_to_rechazos}/${comercio}/transacciones.rech
    echo "Se rechazo por $1 desde el archivo $2 el registro: " >> ${rejected_transactions}
    echo "$3" >> ${rejected_transactions} 
}
function process_registers() {
    idx=1
    while  read -r register || [[ -n "${register}" ]]
    do
        local fields=$(echo "${register}" |  grep -o "," | wc -l)
        if [ ! ${fields} -eq 13 ]; then
            reject_field "cantidad de campos incorrecta" ${file_name} ${register}
        fi
    done
}        
file_name="Lote10105_10" 

function process_file() {
    # echo ${line} | filter_bad_file
    local comercio=$(echo ${file_name} | cut -c 5-9)
    mkdir -p ${path_to_rechazos}/${comercio}
    grep "^" ${path_to_entry}/${file_name} | process_registers
}

process_file