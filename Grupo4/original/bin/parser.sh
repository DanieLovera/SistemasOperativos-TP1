#!/bin/bash

# #PARA FEDEBUR
path_to_log="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/sisop/tpcuotas.log"
path_to_entry="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP"
path_to_lote="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/lotes"
path_to_rechazos="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/rechazos"
path_to_ok="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/ENTRADATP/ok"
path_to_sal="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/SALIDATP"
path_to_terminales="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/original/terminales.txt"
path_to_financiacion="/home/fede/Documentos/sisop/sistemas_operativos_tp1/Grupo4/original/financiacion.txt"

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
}

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
        final_line_1="${file_name},${register}"
        final_line_1="$(echo ${final_line_1} | cut -d "," -f 1,2,3,4,5,6,7,8,9 )"
        final_line_2="$(echo ${register} | cut -d "," -f 9,10,11,12,13,14 )"
        cuotas_aux=$(echo "${register}" | cut -d "," -f7)
        cuotas=$((10#${cuotas_aux}))
        monto_total=$((10#$(echo "${register}" | cut -d "," -f8)))
        fecha_compra=$(echo "${register}" | cut -d "," -f4)
        if [ ${cuotas} -eq 1 ] ; then
            reg_salida="000000000000,${monto_total},001,${monto_total},SinPlan,${fecha_compra}" 
            reg_salida="${final_line_1},${reg_salida},${final_line_2}"
            echo ${reg_salida} >> ${path_to_sal}/${comercio}.txt
        else 
            rubro=$(echo "${register}" | cut -d "," -f6)
            # coef_financiacion=$(grep ${rubro} ${path_to_financiacion} | cut -d "," -f4)
            rubro_aux=$(grep ${rubro} ${path_to_financiacion})
            cuotas_encontradas=$(echo ${rubro_aux}| cut -d "," -f3 | grep "${cuotas_aux}")
            if [ "${cuotas_encontradas}" == "${cuotas_aux}" ] ; then
                # "se encontro financiamiento sin chequear tope"
                tope=$((10#$(echo ${rubro_aux} | grep ${cuotas_aux} | cut -d "," -f5)))
                if [ ${monto_total} -le ${tope} ] ; then
                    reg_salida_caso1
                else
                    reg_salida_caso2
                fi
            else  
                echo "cuotas con interes"
            fi
            
        fi
        reg_salida="${final_line_1},${reg_salida},${final_line_2}"
        idx=$((${idx}+1))
    done
}

function reg_salida_caso2() {
    cuotas_encontradas=$(grep " ," ${path_to_financiacion} | cut -d "," -f3 | grep "${cuotas_aux}")
    if [ "${cuotas_encontradas}" == "${cuotas_aux}" ] ; then
        tope=$(grep " ," "${path_to_financiacion}" | grep "${cuotas_aux}" | cut -d "," -f5)
        tope=$(echo ${tope} | awk '$0*=1')
        if [ ${monto_total} -le ${tope} ] ; then
            coef_financiacion=$(grep " ," ${path_to_financiacion} | grep ",${cuotas_aux}," | cut -d "," -f4)
            plan="Entidad"
            echo "estoy en caso2 y el coef es ${coef_financiacion} y las cuotas ${cuotas_aux}"
            cargar_cuotas_interes
        else
            reg_salida_caso3
        fi
    else 
        reg_salida_3
    fi
}

function reg_salida_caso1() {
    coef_financiacion=$(echo ${rubro_aux} | grep ${cuotas_aux} | cut -d "," -f4)
    plan=$(grep ${rubro} ${path_to_financiacion} | grep ${cuotas_aux} | cut -d "," -f2)
    echo "estoy en caso1"
    cargar_cuotas_interes    
}

function cargar_cuotas_interes() {
    coef_financiacion=$(bc -l <<< "${coef_financiacion}/10000")
    coef_financiacion=$(echo ${coef_financiacion} | grep -o '^[0-9].[0-9]\{4\}')
    echo "el coef vale ${coef_financiacion}"
    monto_original=${monto_total}
    echo "el monto original vale ${monto_original}"
    monto_total=$( bc -l <<< ${monto_original}*${coef_financiacion})
    monto_total=$(echo ${monto_total} | grep -o '^[0-9]*')
    echo "el monto total vale ${monto_total}"
    costo_financiacion=$(bc -l <<< ${monto_total}-${monto_original})
    costo_financiacion=$(echo ${costo_financiacion} | grep -o '^[0-9]*' )
    echo "el costo de financiacion vale ${costo_financiacion}"
    cuota_actual=1
    monto_por_cuota=$(bc -l <<< "${monto_total}/${cuotas}")
    monto_por_cuota=$(echo ${monto_por_cuota} | grep -o '^[0-9]*')
    while [ ${cuota_actual} -le ${cuotas} ]
    do
        sumar_mes 
        reg_salida="${costo_financiacion},${monto_total},00${cuota_actual},${monto_por_cuota},${plan},${fecha_cuota}"
        reg_salida="${final_line_1},${reg_salida},${final_line_2}"
        echo "${reg_salida}" >> ${path_to_sal}/${comercio}.txt
        cuota_actual=$((${cuota_actual}+1))
    done
}

function reg_salida_caso3() {
    cuota_actual=1
    monto_por_cuota=$((${monto_total}/${cuotas}))
    while [ ${cuota_actual} -le ${cuotas} ]
    do
        sumar_mes #funcion que suma un mes al mes actual y crea $fecha_cuota
        reg_salida="000000000000,${monto_total},00${cuota_actual},${monto_por_cuota},SinPlan,${fecha_cuota}"
        reg_salida="${final_line_1},${reg_salida},${final_line_2}"
        echo ${reg_salida} >> ${path_to_sal}/${comercio}.txt
        cuota_actual=$((${cuota_actual}+1))
    done
}

function sumar_mes() {
    local mes=$((10#$(echo ${fecha_compra} | cut -c 5-6 )))
    local dia=$(echo ${fecha_compra} | cut -c 7-8)
    local anio=$(echo ${fecha_compra} | cut -c 1-4)
    local suma_mes=$((${cuota_actual}-1))
    mes=$((${mes}+${suma_mes}))
    if [ ${mes} -gt 12 ] ; then
        mes="$((${mes}-12))"
        anio=$((${anio}+1))
    fi
    fecha_cuota="${anio}0${mes}${dia}"
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
