#!/bin/bash
if [ -z "$GRUPO" -o \
     -z "$DIRCONF" -o \
     -z "$DIRBIN" -o \
     -z "$DIRMAE" -o \
     -z "$DIRENT" -o \
     -z "$DIRRECH" -o \
     -z "$DIRPROC" -o \
     -z "$DIRSAL" ]
then
    error_message "El ambiento no está correctamente inicializado inicializado"
    info_message "Ejecute \"source \$GRUPO/sisop/soinit.sh\" para inicializarlo"
    log_err "El ambiento no está correctamente inicializado inicializado"
    log_inf "Ejecute \"source \$GRUPO/sisop/soinit.sh\" para inicializarlo"
    exit 10
fi

path_to_log="$DIRCONF/tpcuotas.log"
path_to_entry="$DIRENT"
path_to_lote="$DIRPROC"
path_to_rechazos="$DIRRECH"
path_to_ok="$DIRENT/ok"
path_to_sal="$DIRSAL"
path_to_terminales="$DIRMAE/terminales.txt"
path_to_financiacion="$DIRMAE/financiacion.txt"
 

lib_dir="$GRUPO/original/lib"

# include log
. "$lib_dir/log.sh" "$path_to_log"

function reject_file() {
    file_name_rejected="${line}"
    if [ -f "${path_to_rechazos}/${file_name_rejected}" ] 
    then
        file_name_rejected="${line}_duplicate"
    fi 
    mv "${path_to_entry}/${line}" "${path_to_rechazos}/${file_name_rejected}" 
    log_err "${line} se rechazo por $1"
}

function reject_field() {
    local rejected_transactions="${path_to_rechazos}/${comercio}/transacciones.rech"
    echo "$2,$1,$3" >> "${rejected_transactions}"
    log_err "Se rechazo porque $1 desde el archivo $2 el registro: $3"
}

function duplicate() {
    ls "${path_to_entry}" -I 'ok' | \
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		if [  -f  "${path_to_lote}/${line}" ]
        then
            reject_file "estar duplicado"
        fi
	done
}

function filter_lote() {
    ls "${path_to_entry}" -I 'ok' | \
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
        local var=$(echo "${line}" | grep "^Lote[0-9]\{5\}_[0-9]\{2\}$")
		if [ -z "${var}" ]
        then
            reject_file "nombre no valido"
        fi
	done
}

function filter_empty() {
    ls "${path_to_entry}" -I 'ok' | \
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		if [ -s "${line}" ] 
        then
            reject_file "estar vacio"
        fi
	done
}

function move_to_ok() {
    ls "${path_to_entry}" -I 'ok' | \
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		mv "${path_to_entry}/${line}" "${path_to_entry}/ok"
        log_inf "${line} guardado en ok"
	done
}

function filter_files() {
    filter_lote 
    filter_empty
    duplicate
    move_to_ok
}

function process_files() {
    ls ${path_to_entry}/ok | \
    while IFS='' read -r line || [[ -n "${line}" ]]
	do
		echo "${line}" | process_file
	done
}

function process_file() {
    read -r file_name
    local comercio=$(echo "${file_name}" | cut -c 5-9) #substring
    mkdir -p "${path_to_rechazos}/${comercio}"
    grep "^" "${path_to_ok}/${file_name}" | process_registers
    log_inf "Se termino de procesar ${file_name}"
    mv "${path_to_ok}/${file_name}" "${path_to_lote}"
}

function log_missing_registers() {
    msg="En el archivo ${file_name} faltan los registros "
    while [ ${idx} -lt ${index} ]
    do
        msg="${msg}${idx} "
        idx=$((${idx}+1))
    done
    log_err "$msg"
}

function process_registers() {
    idx=1
    idx=$((10#${idx}))
    while read -r register || [[ -n "${register}" ]]
    do
        local fields=$(echo "${register}" |  grep -o "," | wc -l)
        if [ ! ${fields} -eq 13 ]; then
            reject_field "cantidad de campos incorrecta" "${file_name}" "${register}"
        fi
        index=$(echo "${register}" | cut -d "," -f1)
        index=$((10#${index}))

        if [ ${idx} -gt ${index} ] ; then
            reject_field "la secuencia es menor a la esperada" "${file_name}" "${register}"
        fi

        if [ ${index} -gt ${idx} ] ; then
            log_missing_registers
            idx=$((${index}))
        fi

        comercio_code=$(echo "${register}" | cut -d "," -f2 | cut -c 2-6)

        if [ ! ${comercio_code} -eq ${comercio} ] ; then
            reject_field "no coincide el numero de comercio con el nombre del archivo"\ 
            "${file_name}" "${register}"
        fi

        x=$(echo "${register}" | cut -d "," -f2)
        y=$(echo "${register}" | cut -d "," -f3)
        z="${x},${y}"

        terminales_line_found=$(grep "${z}" "${path_to_terminales}")

        if [[ "${z}" != "${terminales_line_found}" ]] ; then
            reject_field "no existe en la tabla maestra terminales.txt" "${file_name}" "${register}"           
        fi
        final_line_1="${file_name},${register}"
        final_line_1="$(echo "${final_line_1}" | cut -d "," -f 1,2,3,4,5,6,7,8,9 )"
        final_line_2="$(echo "${register}" | cut -d "," -f 9,10,11,12,13,14 )"
        cuotas_aux=$(echo "${register}" | cut -d "," -f7)
        cuotas=$((10#${cuotas_aux}))
        monto_total=$((10#$(echo "${register}" | cut -d "," -f8)))
        fecha_compra=$(echo "${register}" | cut -d "," -f4)
        if [ ${cuotas} -eq 1 ] ; then
            reg_salida="000000000000,${monto_total},001,${monto_total},SinPlan,${fecha_compra}" 
            reg_salida="${final_line_1},${reg_salida},${final_line_2}"
            echo "${reg_salida}" >> "${path_to_sal}/${comercio}.txt"
        else 
            rubro=$(echo "${register}" | cut -d "," -f6)
            rubro_aux=$(grep "${rubro}" "${path_to_financiacion}")
            cuotas_encontradas=$(echo "${rubro_aux}" | cut -d "," -f3 | grep "${cuotas_aux}")
            if [ "${cuotas_encontradas}" == "${cuotas_aux}" ] ; then
                # "se encontro financiamiento sin chequear tope"
                tope=$((10#$(echo "${rubro_aux}" | grep "${cuotas_aux}" | cut -d "," -f5)))
                if [ ${monto_total} -le ${tope} ] ; then
                    reg_salida_caso1
                else
                    reg_salida_caso2
                fi
            else  
                reg_salida_caso3
            fi
            
        fi
        reg_salida="${final_line_1},${reg_salida},${final_line_2}"
        idx=$((${idx}+1))
    done
}

function reg_salida_caso2() {
    cuotas_encontradas=$(grep " ," "${path_to_financiacion}" | cut -d "," -f3 | grep "${cuotas_aux}")
    if [ "${cuotas_encontradas}" == "${cuotas_aux}" ] ; then
        tope=$(grep " ," "${path_to_financiacion}" | grep "${cuotas_aux}" | cut -d "," -f5)
        tope=$(echo ${tope} | awk '$0*=1')
        if [ ${monto_total} -le ${tope} ] ; then
            coef_financiacion=$(grep " ," "${path_to_financiacion}" | grep ",${cuotas_aux}," | cut -d "," -f4)
            plan="Entidad"
            cargar_cuotas_interes
        else
            reg_salida_caso3
        fi
    else 
        reg_salida_caso3
    fi
}

function reg_salida_caso1() {
    coef_financiacion=$(echo "${rubro_aux}" | grep "${cuotas_aux}" | cut -d "," -f4)
    plan=$(grep "${rubro}" "${path_to_financiacion}" | grep "${cuotas_aux}" | cut -d "," -f2)
    cargar_cuotas_interes    
}

function cargar_cuotas_interes() {
    coef_financiacion=$(bc -l <<< "${coef_financiacion}/10000")
    coef_financiacion=$(echo "${coef_financiacion}" | grep -o '^[0-9].[0-9]\{4\}')
    monto_original=${monto_total}
    monto_total=$( bc -l <<< ${monto_original}*${coef_financiacion})
    monto_total=$(echo ${monto_total} | grep -o '^[0-9]*')
    costo_financiacion=$(bc -l <<< ${monto_total}-${monto_original})
    costo_financiacion=$(echo "${costo_financiacion}" | grep -o '^[0-9]*' )
    cuota_actual=1
    monto_por_cuota=$(bc -l <<< "${monto_total}/${cuotas}")
    monto_por_cuota=$(echo "${monto_por_cuota}" | grep -o '^[0-9]*')
    while [ ${cuota_actual} -le ${cuotas} ]
    do
        sumar_mes 
        reg_salida="${costo_financiacion},${monto_total},00${cuota_actual},${monto_por_cuota},${plan},${fecha_cuota}"
        reg_salida="${final_line_1},${reg_salida},${final_line_2}"
        echo "${reg_salida}" >> "${path_to_sal}/${comercio}.txt"
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
        echo "${reg_salida}" >> "${path_to_sal}/${comercio}.txt"
        cuota_actual=$((${cuota_actual}+1))
    done
}

function sumar_mes() {
    local mes=$((10#$(echo "${fecha_compra}" | cut -c 5-6 )))
    local dia=$(echo "${fecha_compra}" | cut -c 7-8)
    local anio=$(echo "${fecha_compra}" | cut -c 1-4)
    local suma_mes=$((${cuota_actual}-1))
    mes=$((${mes}+${suma_mes}))
    if [ ${mes} -gt 12 ] ; then
        mes="$((${mes}-12))"
        anio=$((${anio}+1))
    fi
    fecha_cuota="${anio}0${mes}${dia}"
}

cycle=1

while [ true ]; do
    log_inf "voy por el ciclo ${cycle}"
    cycle=$((${cycle}+1))
    filter_files 
    process_files
    sleep 60
done
