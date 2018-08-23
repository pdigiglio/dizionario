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

function get_db_file_list {
    find "${dbPath}" -name "*.tex" -type f
}

# Check if a database has been included in the main file
has_main_db () {
	grep -n --color=auto -i "${dbPath}$1" $mainFile
}

# @param $1 The word
# @param $2 The meaning
# @param $3 (Optional) The output stream
record () {
    local dbFile="`echo ${1:0:1} | tr '[:lower:]' '[:upper:]'`.tex" 

	has_main_db $dbFile > /dev/null
	if [[ $? -ne 0 ]]
	then
		echo "$warning Database `tput setaf 3`$dbFile`tput sgr0` is not in the main file" > /dev/stderr
	fi

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
	local today=`date "+%G-%m-%d"`

    echo ""                                   >> ${output}
    echo "\\newglossaryentry{$1}{% $wordLen"  >> ${output}
    echo "    name        = {$name},% $today" >> ${output}
    echo "    description = {$meaning}%"      >> ${output}
    echo "}"                                  >> ${output}
}

typeset    cmd_line_opts="$(getopt --name "$0" --options "s:c:w:m:o:h" --longoptions "word:,meaning:,output-stream:,search:,check:,main-has-db:,has-main-db:,help,list-db-files" -- "$@")" ec=$?
typeset -r cmd_line_opts
typeset -i ec

if [[ ${ec} -ne 0 ]]
then
    #echo "Could not parse command line options"
    exit 1
fi

eval set -- "${cmd_line_opts}"
# echo "$cmd_line_opts"

typeset word
typeset meaning

while [[ $# -gt 0 ]]
do
	typeset key="$1"
	case "${key}" in
		# Search for word in the database
		"-s" | "--search")
			echo "Look for `tput setaf 3`$2`tput sgr0`" > /dev/stderr
			grep --line-number --color=auto "$2" $dbPath/*.tex
            ec=$?

            if [[ $ec -ne 0 ]]
            then
                echo "No occurrence of '$2' found" > /dev/stderr
            fi

            exit $ec
			;;

        # Check if the database corresponding to the letter has been included
        # in the main file
        "--main-has-db" | "--has-main-db")
            has_main_db "$2"
            exit $?
			;;

        # Check if word exist in database. The idea of this option is that it
        # should not print any user-friendly message: only its error code
        # should matter.
		"-c" | "--check")
			grep "$2" $dbPath/*.tex > /dev/null
			exit $?
			;;

		# Print usage help
		"-h" | "--help")
			echo "TODO: update usage!!"
			help_usage
			;;

        "-w" | "--word")
            word="$2"
            shift
            ;;

        "-m" | "--meaning")
            meaning="$2"
            shift
            ;;

        "-o" | "--output-stream")
            stream="$2"
            shift
            ;;

        "--list-db-files")
            get_db_file_list
            exit $?
            ;;

        "--" )
            break
            ;;
	esac

    shift
done

# Add word to dictionary
if [[ -n "${word}" ]]
then
    record "$word" "$meaning" "$stream"
fi
