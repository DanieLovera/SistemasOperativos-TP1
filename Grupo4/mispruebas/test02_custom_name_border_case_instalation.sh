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
unistall

parameters="directorio-ejecutables\n
tablas maestras\n
novedades\n
rechazados\n
procesados\n
resultados\n
SI\n"

correct_instalation="$(echo -e $parameters | regular_install | grep "Estado de la instalación: .*COMPLETADA")"
if [ -z "$correct_instalation" ]
then
    errors[last_error++]="Debería poder instalar el sistema e indicarlo por stdout"
    success=1
fi

make_test_dir

save_logs
save_conf

if [ ! -d "$group_dir/directorio-ejecutables" -o \
     ! -d "$group_dir/tablas maestras" -o \
     ! -d "$group_dir/novedades" -o \
     ! -d "$group_dir/rechazados" -o \
     ! -d "$group_dir/procesados" -o \
     ! -d "$group_dir/resultados" ]
then
    errors[last_error++]="Debería haber creado las carpetas con los nombres custom"
    success=1
fi

remove_org_logs
unistall

correct_logging="$(show_log "sotp1.log" | grep "Estado de la instalación: .*COMPLETADA")"
if [ -z "$correct_logging" ]
then
    errors[last_error++]="Debería escribir en el log que pudo instalarlo exitosamente"

    success=1
fi

correct_logging="$(show_log "tpcuotas.log")"
if [ -n "$correct_logging" ]
then
    errors[last_error++]="No debería escribir en tpcuotas.log"
    success=1
fi

correct_logging="$(show_log "soinit.log")"
if [ -n "$correct_logging" ]
then
    errors[last_error++]="No debería escribir en soinit.log"
    success=1
fi

rm -rf "$group_dir/directorio-ejecutables"
rm -rf "$group_dir/tablas maestras"
rm -rf "$group_dir/novedades"
rm -rf "$group_dir/rechazados"
rm -rf "$group_dir/procesados"
rm -rf "$group_dir/resultados"

show_result $success errors
