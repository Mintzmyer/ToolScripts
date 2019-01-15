#!/bin/bash
#
# This script is intended to rapidly automate a process on-the-fly
#     by letting the user select from recent command history and
#     then run that subset of commands repeatedly
#
# It separates each command execution by a keystroke from the user
#
# This is ideal for situations where a process is repetitive, but
#     dynamic. In cases that do not quite warrant their own script,
#     it removes up-arrowing or reverse-searching through history
#     over and over again. A dynamic hotkey.

# Default number of previous commands
histNum=11

# Allows the user to select a subset of commands from recent history to hotkey
setup(){
    recentCMDS=()
    unset recentCMDS
    i=1
    while read -r line;
    do
        line="${line#* }";
        recentCMDS+=( "$i" );
        recentCMDS+=( "$line" );
        recentCMDS+=("off"); 
        i=$((i+1))
    done < <( history $histNum )

    CMDS=$(whiptail --checklist --separate-output "Please select commands" \
    $((histNum+6)) 60 $histNum "${recentCMDS[@]}" 3>&1 1>&2 2>&3)
}

# Execute the subset of commands assigned to the hotkey
auto(){
    for cmd in $CMDS
    do
        read -n 1 -s -r -p "${recentCMDS[((cmd-1)*3)+1]} or press [r] to repeat prev"
        echo ""
	while [[ "$REPLY" =~ ^[Rr]$ ]]; do
            ${recentCMDS[((cmd-2)*3)+1]}
            read -n 1 -s -r -p "${recentCMDS[((cmd-1)*3)+1]} or press [r] to repeat prev"
            echo ""
	done
        ${recentCMDS[((cmd-1)*3)+1]}
    done
}

# Command Line Interface
argNum=$#
if [ "$argNum" -ge 1 ]; then
    echo "Usage: $ source ~/uparrow.sh [-s [#]]"
    echo "Quickly automate recently used commands for fast repetition"
    arg1=$1
    if [ "$arg1" = "-h" ]; then
        echo "    -s    Select a subset from the 11 most recent commands"
        echo "    -s #  Select a subset from the # most recent commands"
        echo "    -h    Shows this help message"
        echo "    Note: It's critical to use source or a preceding '.'"
        echo "          to gather history from current shell"
    elif [ "$arg1" = "-s" ]; then
        if [ "$argNum" -ge 2 ]; then
            histNum=$2
        fi
        setup
    fi
else
    auto
fi
