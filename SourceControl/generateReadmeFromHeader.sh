#!/bin/bash
#
# This script performs the linux/unix specific work
#     of feeding files to the readmeGenerator
#

g++ generateReadmeFromHeader.cpp -o readmeGenerator

# Initialize README for update
./readmeGenerator;

# Update all files in the directory
if [ $? -eq 0 ]; then
    for file in $(ls $(pwd)); do
        ./readmeGenerator "$(pwd)" "$file";
    done
fi

# Clean up
rm readmeGenerator
