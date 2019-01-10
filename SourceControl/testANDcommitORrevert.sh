#!/bin/bash

# This script implements an idea by Oddmund Strømmer, 
#     and popularized by Kent Beck, described here:
#     https://medium.com/@kentbeck_7670/test-commit-revert-870bbd756864
#     which I first heard about on HanselMinutes podcast here:
#     https://player.fm/series/hanselminutes-fresh-talk-and-tech-for-developers/test-commit-revert-with-kent-beck
#
# 'Test && Commit || Revert' is a workflow that seeks to 1up "Limbo On The Cheap"s
#     'Test && Commit' by strongly encouraging programmers to make as small,
#     incremental changes as possible...because if their tests fail their changes
#     are reverted and lost! This reduces Sunk Cost Fallacy waste.
#
# This script's intention is to make a generic impelementation of the workflow
#     so that it's all ready to experiment with when I have the opportune project


# The location of the source code, excluding the test code
sourceLocation="/path/to/source/location/dir/"

# Compile the source code and report the result
buildFn(){
    echo "Building";
    # Add code to build source
    return $?; # Pass on build result
}

# Execute tests and report the results
testFn(){
    echo "Testing";
    # Add call to execute tests
    return $?; # Pass on test results
}

# Commit the changes, write a brief commit message (opted against auto-msg)
commitFn(){
    echo "Commit!"
    # git commit -a
}

# Revert the changes
revertFn(){
    # git reset --hard creates an impasse when adding tests that the
    # code currently fails but needs to pass...should tests and code
    # be co-developed, or should tests be written and then code added
    # to pass the new tests? Trying the latter, for now:
    echo "Revert!"
    # git checkout HEAD - "$sourceLocation"
}

echo "    ----    build && ( test && commit || revert )    ----";
echo "";

if buildFn; then
    if testFn; then
        commitFn;
    else
        revertFn;
    fi
fi

echo "";
echo "    Test Driven Development Laws, Refactored";
echo "        1) Write only enough of a unit test to fail";
echo "        2) Write only enough production code to make a failing unit test pass";
