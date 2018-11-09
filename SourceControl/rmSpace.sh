#!/bin/bash

    # Set Internal Field Separator to '\n' linebreak #
IFS='
'

    # Iterate through items in dir whose name may contain spaces #
ls $(pwd) | while read line;
do
    echo $line
    name=$line
    name=${name/ - /-}
    name=${name/: /:}
    name=${name// /_}

        # If the reformating rules apply, rename the item #
    if [ "$line" != "$name" ]; then
        echo "--------->Changed to: '$name' "
        mv $line $name
    else
        echo "->no reformatting needed"
    fi

done

