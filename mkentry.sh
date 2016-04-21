#!/bin/sh

record () {
    local dbPath="listeParole/"
    echo " > Recording `tput setaf 3`$1`tput sgr0` into " \
        "`tput setaf 2`${dbPath}`echo ${1:0:1} | tr '[:lower:]' '[:upper:]'`.tex `tput sgr0`" > /dev/stderr

    echo "\\newglossaryentry{$1}{%"
    echo "    name        = {$1},%"
    echo "    description = {}%"
    echo "}"
}

record $1
