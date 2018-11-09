#!/bin/bash
saveMsg=" Checkpoint @ $(date)"
q='"'

if [ "$#" -ge 1 ]; then
    comment=$1
    saveMsg=$q$comment$q$saveMsg
fi

find / -name ".git" 2> >(grep -v 'Permission denied' >&2) | while read line;
do
    echo "Processing file '$line'";
    path=${line::-4}
    mods=$(git -C $path stash save --all $saveMsg);
    if [ "$mods" != "No local changes to save" ]; then
        git -C $path stash apply;
    fi
done


