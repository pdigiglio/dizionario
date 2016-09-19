#!/bin/bash

# Import some variables
. commonVariables.sh

histoDataFile="histoData.dat"
histoInitialsDataFile="histoDataInitials.dat"
histoScript="mkHistogram.gpl"
histoInitialsScript="mkHistogramInitials.gpl"

extract_histo_data () {
	# Check if output is forced
	if [[ -z "$1" ]]
	then
		output="$histoDataFile"
	else
		output="$1"
	fi

	# Extract relevant data and override previous data file (if any)
    grep "newglossaryentry" ${dbPath}/*.tex | cut -f2 -d% | sed 's/^\ //' > $output # | sort --numeric-sort
}

extract_histo_initials () {
	for i in $(ls -1 ${dbPath})
	do
		sed '/^\s*$/d' ${dbPath}$i | wc -l
	done
}

while [[ $# -ge 1 ]]
do
	key="$1"
	case $key in 
		--to-stdout)
			extract_histo_data "/dev/stdout"
#			shift
			;;

		--to-stderr)
			extract_histo_data "/dev/stderr"
#			shift
			;;

		-c|--count)
			extract_histo_data "/dev/stdout" | wc -l
#			shift
			;;

		-o|--output)
			if [[ !( -z "$2" ) ]]
			then
				extract_histo_data "$2"
				shift
			else
				echo "Empty file name. Exiting." > /dev/stderr
				exit 1
			fi
			;;

		--get-default-output)
			echo `pwd`"$histoDataFile"
#			shift
			;;

		-h|--help)
			echo "TODO: usage"
#			shift
			;;

		--make)
			extract_histo_data "$histoDataFile"&& gnuplot $histoScript #&& xdg-open `echo $histoDataFile| sed 's/.dat/.png/'`&
#			shift
			;;
		--visualize)
			extract_histo_data "$histoDataFile"&& gnuplot $histoScript&& xdg-open `echo $histoDataFile| sed 's/.dat/.png/'`&
#			shift
			;;
		--initials)
			extract_histo_initials > $histoInitialsDataFile && gnuplot $histoInitialsScript
			shift
			;;
		*)
			extract_histo_data "$histoDataFile"
			;;
	esac
	shift
done
