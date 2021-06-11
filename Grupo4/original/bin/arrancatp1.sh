
EXECUTABLE="$DIRBIN/parser.sh" # Debería ser cuotatp

# @return 0 si el proceso principal está seteado y está corriendo
# 1 en caso contrario
# TODO: Esto está duplicado
function check_if_program_running() {
	if [[ -n $TP_PID && -e /proc/$TP_PID ]]
	then
		return 0
	else
		return 1
	fi
}


# TODO: Esto está duplicado
function run_tp_scripts() {
	"$EXECUTABLE" &
	TP_PID="$!"
	export TP_PID
}

function run() {
    check_if_program_running
	if [ $? -eq 0 ]
	then
		# show_stop_program_guide TODO: hacer el import
        echo ""
	else
        run_tp_scripts
    fi


}

run