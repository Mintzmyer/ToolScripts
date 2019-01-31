#!/bin/bash
#
# This script performs the linux/unix specific work
#     of feeding files to the readmeGenerator
#

echo "usage: ./generateReadmeFromHeader.sh [directory]"
# Get directory that the script resides in
#     - this allows it to be run from anywhere
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set the directory for the documentation,
#    - either from a CLA or where it was called from
if [ $# -gt 0 ]; then
    DOCDIR=$1
else
    DOCDIR="$(pwd)"
fi

# Compile c++ source
g++ "$SRCDIR/"generateReadmeFromHeader.cpp -o readmeGenerator

# Initialize README for update
./readmeGenerator "$DOCDIR";

# Update all files in the directory
if [ $? -eq 0 ]; then
    for file in $(ls "$DOCDIR"); do
        ./readmeGenerator "$DOCDIR" "$file";
    done
fi

# Clean up
rm readmeGenerator
