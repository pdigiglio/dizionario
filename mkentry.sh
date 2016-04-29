#!/bin/bash

# Import some variables
. commonVariables.sh

help_usage () {
	echo "Usage:"
	echo " bash mkentry.sh \"<word>\" \"<meaning>\" (\"<out_stream>\")"
}

capitalize_first_letter () {
    echo "$1" | sed 's/^./\U&/'
}

# Suppress end punctuation and spaces
# TODO Don't remove '}'!
suppress_end_punctuation () {
    echo "$1" | sed 's/[[:punct:]]$//' | sed 's/\s*$//'
}

is_duplicate () {
    # Shows the output and the file on the screen
    grep -n -A4 --color=auto "\newglossaryentry{$1}" ${dbPath}/*.tex # > /dev/null

    if [[ "$?" -eq "0" ]]
    then
        echo ""                                                         > /dev/stderr
        echo "${error} duplicate entry. Please edit the file manually." > /dev/stderr
        exit 1 
    fi

}

record () {
    local dbFile="`echo ${1:0:1} | tr '[:lower:]' '[:upper:]'`.tex" 

	# meaning is mandatory: if it's empty, exit with error
	if [[ -z "$2" ]]
	then
		echo "$error word meaning is mandatory. Exiting." > /dev/stderr
		help_usage
		exit 2
	fi

    # if one specifies an output file
    if [[ !( -z "$3" ) ]]
    then
        local output="$3"
    else
        local output="${dbPath}${dbFile}"
    fi
    
    local wordLen=`echo -n "$1" | wc --char`

    [[ !( -w ${output} ) ]] && echo "${warning} file ${output} doesn't exist"

    is_duplicate $1 $dbPath $output

    echo " > Recording `tput setaf 3`$1`tput sgr0` ($wordLen) into " \
         "`tput setaf 2`${output}`tput sgr0`" > /dev/stderr

    # if meaning is not empty
    if [[ !( -z "$2" ) ]]
    then
        # Capitalize first letter and suppress end point
        local meaning=`capitalize_first_letter "$(suppress_end_punctuation "$2")"`
        echo " > with the meaning: `tput setaf 4`$meaning`tput sgr0`"
    fi

    # Capitlize name field
    local name=`capitalize_first_letter "$1"`

    echo ""                                  >> ${output}
    echo "\\newglossaryentry{$1}{% $wordLen" >> ${output}
    echo "    name        = {$name},%"       >> ${output}
    echo "    description = {$meaning}%"     >> ${output}
    echo "}"                                 >> ${output}
}

record "$1" "$2" "$3"
