
RESET="\e[0m"
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"

function bold() {
	echo -e "$BOLD$1$RESET"
}

function display_ok() {
	echo -e "${GREEN}${BOLD}OK${RESET}"
}

function error_message() {
	echo -e "$RED[ERROR]$RESET $1"
}

function info_message() {
	echo -e "$BLUE[INFO]$RESET $1"
}

function success_message() {
	echo -e "$GREEN[SUCCESS]$RESET $1"
}