#!/bin/bash
LOG_FILE=$1 # TODO: Ver si sigue guncionando con varios includes

function log() {
	echo "$1-$(date "+%d/%m/%Y %H:%M:%S")-$2-$(whoami)" >> "$3"
}

# Loggea INF a LOG_FILE
# @param $1: mensaje que se adjuntara en el log.
function log_inf() {
    log "INF" "$1" "$LOG_FILE"
}

# Loggea WAR a LOG_FILE
# @param $1: mensaje que se adjuntara en el log.
function log_war() {
    log "WAR" "$1" "$LOG_FILE"
}

# Loggea ERR a LOG_FILE
# @param $1: mensaje que se adjuntara en el log.
function log_err() {
    log "ERR" "$1" "$LOG_FILE"
}
