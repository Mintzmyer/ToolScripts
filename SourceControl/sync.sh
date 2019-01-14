#!/bin/bash
#
# This script automates the sync functionality, making it
#     easier to stay up to date with everyone's changes,
#     even if they touch source that you're not currently
#     working on or even thinking about.
#

defaultDir=~/
altDir1=~/
altDir2=~/
altDir3=~/
saveMsg='"Auto-sync on '$(date)'"'

buildDir=$defaultDir
leaveStashed=0

    # Check if User wants to stash everything #
if [ "$#" -ge 1 ]; then
    arg1=$1
    if [ "$arg1" = "-s" ]; then
        leaveStashed=1
    fi
fi

    # Sync android build #
cd $buildDir
repo sync;
repo rebase;

    # Find all git repos and sync them #
find ~/ -name ".git" 2> >(grep -v 'Permission denied' >&2) | while read line;
do
    echo "Processing file '$line'";
    path=${line::-4}
    git -C $path fetch;
    mods=$(git -C $path stash save --all $saveMsg);
    git -C $path rebase;

        # Reapply local changes unless User requests them stashed #
    if [ "$mods" != "No local changes to save" ]; then
        if [ leaveStashed -ne 1 ]; then
            git -C $path stash apply;
        fi
    fi
done
