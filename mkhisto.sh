#!/bin/bash

# Import some variables
. commonVariables.sh

extract_histo_data () {
    grep "newglossaryentry" ${dbPath}/*.tex | cut -f2 -d% | sed 's/^\ //' # | sort --numeric-sort
}

extract_histo_data
