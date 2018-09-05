#!/bin/bash

# This script is intended to automate testing of an Android device's boot 
#     process by observing the print statements from the start up sequence
#     
# It presumes that the failure condition causes the device to crash
#     thus it only restarts if the device boot succeeds
#
# This script listens in to a serial port, presumably being fed RS232
#     or equivalent, from the device
#
# This script is written to be light-weight and modifiable, rather than
#     covering all or many of the use cases with fleshed out flag options

fail=0
failCount=0
succ=0
succCount=0
totCount=-1
reboot=0

declare -a PRINTABLES

if [ "$#" -ge 3 ]; then
    PRINTABLES=( "$@" )
# Defaults for a particular use case
elif [ "$#" -eq 0 ]; then
    PRINTABLES[0]="Could not find gpio-key"
    PRINTABLES[1]="Monitoring key"
    PRINTABLES[2]="U-Boot"
    PRINTABLES[3]=">^_^<" # A string contained in all print statements that were added to debug this issue
else
    echo "Usage: RebootTester.sh <failure condition> <success condition> <boot condition> [<print conditions>...]"
    echo "    <failure condition>    A key string to search for that likely indicates a failed boot"
    echo "    <success condition>    A key string to search for that likely indicates a successful boot"
    echo "    <boot condition>       A key string to search for that likely indicates the start of a boot"
    echo "    <print conditions>     [Optional+] Key strings to print if found"
    exit 0
fi

# Set first 3 indexes to variables, for readability
failCond=${PRINTABLES[0]}
succCond=${PRINTABLES[1]}
bootCond=${PRINTABLES[2]}

sudo chmod 0777 /dev/ttyUSB0

# Tell the user what is being tallied
echo "Using:"
echo "fail condition = '"$failCond"'"
echo "success condition = '"$succCond"'"
echo "boot condition = '"$bootCond"'."
echo "Please close anything that might also be listening in on the serial port to the device"
echo "Press [Ctrl-c] to exit"
echo ""
echo "Setting baud rate:"
stty speed 115200 < /dev/ttyUSB0
echo ""
echo "Reboot the device to begin testing"

# Seek out print statements of interest
cat -v < /dev/ttyUSB0 | while read line;
do
    for printable in "${PRINTABLES[@]}"
    do
        if [[ $line = *"$printable"* ]]; then
            echo $line
        fi
    done
    if [[ $line = *"$failCond"* ]]; then
        fail=1
    fi
    if [[ $line = *"$succCond"* ]]; then
        succ=1
    fi
    # This logic insures multiple success statements send only one reboot message
    if [[ $succ -eq 1 ]] && [[ $reboot -eq 0 ]]; then
        reboot=1
        sleep 4
        echo "reboot" > /dev/ttyUSB0
    fi
    # Tallies results of most recent boot
    if [[ $line = *"$bootCond"* ]]; then
        reboot=0
        failCount=$((failCount+fail))
        fail=0
        succCount=$((succCount+succ))
        succ=0
        totCount=$((totCount+1))
        echo ""
        echo "RebootTester progress: Total: "$totCount" | Fails: "$failCount" | Successes: "$succCount""
    fi
done

