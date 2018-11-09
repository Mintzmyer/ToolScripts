#!/bin/bash
prefix="modified:   "

chooseEditor(){
    if [[ $(command -v bcommand) ]]; then
        # Use ripgrep if available
	editor="bcommand"
    else
        editor="meld"
    fi
}

echoFiles(){
    echo "  ~~~  Tracked files:  ~~~  "
    for file in $(git -C "$repo" ls-files); do
        echo "   -$file"
    done
    echo "  ~~~  Untracked files:  ~~~  "
    for file in $(git -C "$repo" ls-files -o); do
        echo "   -$file"
    done
}

reviewFiles(){
    echo ""
    echo " ~> Tracked files:"
    for file in $(git -C "$repo" ls-files); do
        git -C "$repo" difftool "$file"
    done
    echo " ~> Untracked files:"
    echo ""
    for file in $(git -C "$repo" ls-files -o); do
        echo "Viewing: '$file'"
        read -p "Launch '$editor' Y/n?: " -n 1 -r REPLY </dev/tty
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $editor "$file"
        fi
        echo ""
    done
}

addFiles(){
    echo "Tracked files:"
    for file in $(git -C "$repo" ls-files); do
        read -p "`echo $'\n > '`Add $file? Y/n: " -n 1 -r REPLY </dev/tty
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$repo" add "$file"
        fi
    done
    echo "Untracked files:"
    for file in $(git -C "$repo" ls-files -o); do
        read -p "`echo $'\n > '`Add $file? Y/n: " -n 1 -r REPLY </dev/tty
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$repo" add "$file"
        fi
    done
}

commitChanges(){
    echo "# New commit or amend?"
}

uploadCommit(){
    echo "# Repo upload or git review?"
}

main(){
    # Find all repos that contain changes #
    for repo in $(find "$path" -name "*.git"); do
        repo=${repo::-4}
        diff=$(git -C "$repo" status | grep "Changes")

        # If repo contains changes #
        if [ "$diff" != "" ]; then
            echoFiles

            # ~~~ Review ~~~ #
            if [ "$review" -eq 1 ]; then
                # Ask user to review files #
                read -p "`echo $'\n > '`Review files in $repo? Y/n: " -n 1 -r REPLY </dev/tty
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    reviewFiles
                fi
            fi

            # ~~~ Commit ~~~ #
            if [ "$commit" -eq 1 ]; then
		# Ask user to stage files
                read -p "`echo $'\n > '`Stage changes in $repo? Y/n: " -n 1 -r REPLY </dev/tty
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
		    echo "Add files"
                    #addFiles
                fi
		# Ask user to commit files
                read -p "`echo $'\n > '`Commit changes in $repo? Y/n: " -n 1 -r REPLY </dev/tty
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
		    echo "Commit files"
                    #commitChanges
                fi
		# Ask user to upload commit
                read -p "`echo $'\n > '`Upload commit in $repo? Y/n: " -n 1 -r REPLY </dev/tty
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
		    echo "Upload commit"
                    #uploadCommit
                fi

            fi

        fi
    done
}

# See if user has BeyondCompare or Meld, set accordingly
chooseEditor

review=1
commit=0
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "Usage: $~/review.sh [Options] <path>"
            echo "Recursively search <path> for modified git repos, review and commit"
            echo "    -r          Only review, don't stage or commit any changes"
            echo "    -c          Only stage and commit changes, don't review them"
            echo "    <path>      String to search for repos changed"
            echo "    -h          Show this help message"
            exit 0
            ;;
        -r)
            review=1
            commit=0
            echo "Redundant flag: Default behavior is just review"
            shift
            ;;
        -c)
            review=0
            commit=1
            shift
            ;;
        -rc|-cr)
            review=1
            commit=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "$#" -eq 1 ]; then
    path=$1
else
    echo "Usage: $~/review.sh [Options] <path>"
    exit 0;
fi

# Main function #
main
echo $'\n'
