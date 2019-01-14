#!/bin/bash
#
# This script is intended to perform a recursive search and replace
#     for files and directories, and/or file contents much like 
#     vim's (sed) %s/search/replace/gc for a single file
# 
# This is useful in large projects when a naming convention or
#     new standard needs to be implemented across the board

    # Set Internal Field Separator to '\n' linebreak #
IFS='
'
    # Iterate through names of files and directories #
sedName(){
    for line in $(find $(pwd) -name "*$search*"); do
        name=$line
        name=${name//$search/$replace}
	echo "$line -->"
        read -p "$name? Y/n: " -n 1 -r REPLY </dev/tty
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv $line $name
        fi
        echo ""
    done
}

    # Iterate through file contents #
sedContent(){
    srchTool="grep -r"
    editor="vi"
    if [[ $(command -v rg) ]]; then
        # Use ripgrep if available
	srchTool="rg"
    fi
    if [[ $(command -v vim) ]]; then
        # Use vim if available
	editor="vim"
    fi
    for i in $("$srchTool" -l "$search" "$(pwd)" ); do
        $editor -c '%s/'$search'/'$replace'/gc' -c 'wq' $i;
    done
}

# Command Line Interface
names=1
contents=1

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "Recursively search current directory and renaming it"
            echo "    -n          Act only on Names, both directory and file names"
            echo "    -c          Act only on Contents of the files"
            echo "    <search>    String to search file+directory names for"
            echo "    <replace>   String to replace file+directory names with"
            echo "    -h          Show this help message"
            exit 0
            ;;
        -n)
            names=1
            contents=0
            shift
            ;;
        -c)
            names=0
            contents=1
            shift
            ;;
        -nc|-cn)
            names=1
            contents=1
            echo "Redundant flags: Default behavior is both names and contents"
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "$#" -ge 2 ]; then
    arg1=$1
    arg2=$2
    search=$arg1
    replace=$arg2
    echo "Search: $search Replace: $replace"
else
    echo "Usage: $~/rename.sh [Options] <search> <replace>"
    exit 0;
fi

if [ "$names" -eq 1 ]; then
    sedName
fi

if [ "$contents" -eq 1 ]; then
    sedContent
fi

