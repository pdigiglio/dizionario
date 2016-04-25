#!/bin/bash

# Import some variables
. commonVariables.sh

histoDataFile="histoData.dat"

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

extract_histo_data "$1"
