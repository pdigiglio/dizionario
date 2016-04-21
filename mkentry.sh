#!/bin/sh

record () {
    local dbPath="listeParole/"
    local dbFile="`echo ${1:0:1} | tr '[:lower:]' '[:upper:]'`.tex" 

    # if one specifies an output file
    if [[ !( -z "$3" ) ]]
    then
        local output="$3"
    else
        local output="${dbPath}${dbFile}"
    fi
    
    local wordLen=`echo -n "$1" | wc --char`

    [[ !( -w ${output} ) ]] && echo "WARNING: file ${output} doesn't exist"

    echo " > Recording `tput setaf 3`$1`tput sgr0` ($wordLen) into " \
         "`tput setaf 2`${output}`tput sgr0`" > /dev/stderr

    # if meaning is not empty
    if [[ !( -z "$2" ) ]]
    then
        # Capitalize first letter
        local meaning=`echo "$2" | sed 's/^./\U&/'`
        echo " > with the meaning: `tput setaf 4`$meaning`tput sgr0`"
    fi

    # Capitlize name field
    local name=`echo "$1" | sed 's/^./\U&/'`

    echo ""                                  >> ${output}
    echo "\\newglossaryentry{$1}{% $wordLen" >> ${output}
    echo "    name        = {$name},%"       >> ${output}
    echo "    description = {$meaning}%"     >> ${output}
    echo "}"                                 >> ${output}
}

record "$1" "$2" "$3"
