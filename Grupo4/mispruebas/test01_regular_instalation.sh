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
correct_instalation="$(fast_install | grep "Estado de la instalación: .*COMPLETADA")"
if [ -z "$correct_instalation" ]
then
    errors[last_error++]="Debería poder instalar el sistema e indicarlo por stdout"
    success=1
fi
make_test_dir
save_logs
save_conf

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

show_result $success errors
