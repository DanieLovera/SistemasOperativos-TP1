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
parameters="ejecutables\n
tablas\n
novedades\n
rechazados\n
procesados\n
resultados\n
SI\n"

echo -e $parameters | regular_install > /dev/null
init_env > /dev/null
make_test_dir
save_logs
save_conf

correct_logging="$(show_log "soinit.log")"
if [ -z "$correct_logging" ]
then
    errors[last_error++]="Debería escribir en soinit.log"
    success=1
fi

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


if [[ "$GRUPO" != "$group_dir"  || \
      "$DIRCONF" != "$group_dir/sisop"  || \
      "$DIRBIN" != "$group_dir/ejecutables"  || \
      "$DIRMAE" != "$group_dir/tablas"  || \
      "$DIRENT" != "$group_dir/novedades"  || \
      "$DIRRECH" != "$group_dir/rechazados"  || \
      "$DIRPROC" != "$group_dir/procesados"  || \
      "$DIRSAL" != "$group_dir/resultados"  ]]
then
    errors[last_error++]="Debería haber inicializado el entorno con los valores correctos"
    success=1
fi

if [ -z "$(show_log "soinit.log" | grep "El sistema arrancó con pid")" ]
then
    errors[last_error++]="Debería haber inicializado el proceso e indicado el pid"
    success=1
fi


test_stop_main_process > /dev/null

remove_org_logs
unistall
uninit

rm -rf "$group_dir/ejecutables"
rm -rf "$group_dir/tablas"
rm -rf "$group_dir/novedades"
rm -rf "$group_dir/rechazados"
rm -rf "$group_dir/procesados"
rm -rf "$group_dir/resultados"

show_result $success errors
