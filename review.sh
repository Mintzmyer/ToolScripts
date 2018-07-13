#!/bin/bash
prefix="modified:   "

    # Check if User wants #
if [ "$#" -ge 1 ]; then
    arg1=$1
    if [ "$arg1" = "-s" ]; then
        arg1=2
    fi
fi

    # Review all modified files #
path=$(pwd)
git -C $path status | grep "modified:" | while read line;
do
    file=${line#$prefix} 
    echo "Press any key to review file '$file'";

    while : ; do
        read -n1 -rs key <&1
        if [ "$key" = '' ] ; then
            break
        fi
    done
    meld $file
done

