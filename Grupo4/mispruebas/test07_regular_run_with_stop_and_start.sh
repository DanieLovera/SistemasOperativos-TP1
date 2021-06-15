test_dir="$(dirname "$(realpath "$0")")"
group_dir="$(dirname "$test_dir")"
conf_dir="$group_dir/sisop"

TEST_FILE_NAME="$(basename "$0")"

# include test_utils.sh
. "$test_dir/test_utils.sh" "$TEST_FILE_NAME"

# include pprint
. "$group_dir/original/lib/pprint.sh"

success=0
last_error=0
errors=()

uninit
unistall

fast_install > /dev/null
init_env > /dev/null

make_test_dir
save_logs
save_conf

if [ -z "$(show_log "soinit.log" | grep "Directorios del sistema")" ]
then
    errors[last_error++]="Debería haber analizado los directorios del sistema"
    success=1
fi

if [ -z "$(show_log "soinit.log" | grep "Archivos del sistema")" ]
then
    errors[last_error++]="Debería haber analizado los archivos del sistema"
    success=1
fi

if [ -z "$(show_log "soinit.log" | grep "Permisos de tablas maestras y ejecutables")" ]
then
    errors[last_error++]="Debería haber analizado los los permisos de las tablas y los ejecutables"
    success=1
fi

if [ -z "$(show_log "soinit.log" | grep "Se inició el ambiente correctamente")" ]
then
    errors[last_error++]="Debería haber indicado que se inicializó el entorno"
    success=1
fi

if [ -z "$GRUPO" -o \
     -z "$DIRCONF" -o \
     -z "$DIRBIN" -o \
     -z "$DIRMAE" -o \
     -z "$DIRENT" -o \
     -z "$DIRRECH" -o \
     -z "$DIRPROC" -o \
     -z "$DIRSAL" ]
then
    errors[last_error++]="Debería haber inicializado el entorno"
    success=1
fi

if [ -z "$(show_log "soinit.log" | grep "El sistema arrancó con pid")" ]
then
    errors[last_error++]="Debería haber inicializado el proceso e indicado el pid"
    success=1
fi

stop_output="$(test_stop_main_process)"
if [ -z "$(echo "$stop_output" | grep "Se pudo detener el sistema")" ]
then
    errors[last_error++]="Debería haber finalizado el programa"
    success=1
fi

stop_output="$(test_stop_main_process)"
if [ -z "$(echo "$stop_output" | grep "El sistema ya está detenido.")" ]
then
    errors[last_error++]="Debería haber indicado que el programa está detenido"
    success=1
fi


stop_output="$(test_stop_main_process)"
if [ -z "$(echo "$stop_output" | grep "Para poder arrancar el sistema, ejecute")" ]
then
    errors[last_error++]="Debería haber indicado cómo arrancar el sistema"
    success=1
fi
test_start_main_process > /dev/null


start_output="$(test_start_main_process)"
if [ -z "$(echo "$start_output" | grep "Proceso ya corriendo")" ]
then
    errors[last_error++]="Debería indicar que el programa ya está corriendo"
    success=1
fi

start_output="$(test_start_main_process)"
if [ -z "$(echo "$start_output" | grep "Para poder cortar esa ejecución ejecute")" ]
then
    errors[last_error++]="Debería indicar cómo frenar el proceso"
    success=1
fi

remove_org_logs
test_stop_main_process > /dev/null
unistall
uninit

show_result $success errors
