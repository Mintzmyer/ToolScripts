#!/bin/bash
#
# This script is intended to review and commit changes to large projects
#     which have multiple git repositories, and a particular feature or fix
#     might touch multiple parts of the source code
#
# It helps users leverage version control tools like reviewing all changes
#     and commit multiple related changesets in separate repos
#
# It gives a birds-eye view of changes and prevents partial checkins
#

prefix="modified:   "

## Function to get char+enter from user and return char  ##
getBtnPress(){
    if [[ $# -lt 1 ]]; then
         prompt="Make a selection?"
    else
         prompt=$1
    fi
    read -p "$prompt" -n 2 -r REPLY </dev/tty
    echo -n $REPLY
}

## Function to find editor, I prefer BeyondCompare ##
chooseEditor(){
    if [[ $(command -v bcommand) ]]; then
        # Use ripgrep if available
	editor="bcommand"
    else
        editor="meld"
    fi
}

## Function to print all modified/deleted/new files in a repository ##
echoFiles(){
    echo "  ~~~  Tracked files:  ~~~  "
    for file in $(git -C "$repo" ls-files -m -d); do
        echo "   -$file"
    done
    echo "  ~~~  Untracked files:  ~~~  "
    for file in $(git -C "$repo" ls-files -o); do
        echo "   -$file"
    done
}

## Function to review modified files with difftool or new files ##
reviewFiles(){
    echo ""
    echo " ~> Tracked files:"
    for file in $(git -C "$repo" ls-files -m -d); do
        git -C "$repo" difftool "$file"
    done
    echo " ~> Untracked files:"
    echo ""
    for file in $(git -C "$repo" ls-files -o); do
        echo "Viewing: '$file'"
        REPLY=$(getBtnPress "Launch '$editor' Y/n?: ")
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $editor "$file"
        fi
        echo ""
    done
}

## Function to add/stage modified/deleted/new files for commit ##
addFiles(){
    echo ""
    # Show modified, deleted, and untracked files
    for file in $(git -C "$repo" ls-files -m -d -o); do
        REPLY=$(getBtnPress "Add $file? Y/n: ")
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git -C "$repo" add "$file"
        fi
    done
}

## Function to commit changeset ##
commitChanges(){
    cmd="git -C "$repo" commit "

    # Fresh commit or --amend?"
    REPLY=$(getBtnPress "Would you like to start a fresh commit or --amend? f/a: ")
    if [[ $REPLY =~ ^[Aa]$ ]]; then
        cmd="$cmd --amend"
    fi
    $cmd
}

## Function to upload commit using repo upload or git review ##
uploadCommit(){
    echo "# Repo upload or git review?"
    # Repo Upload or git review?"
    REPLY=$(getBtnPress "Use repo upload or git review? r/g: ")
    if [[ $REPLY =~ ^[Rr]$ ]]; then
	repo upload $repo
    elif [[ $REPLY =~ ^[Gg]$ ]]; then
	git -C "$repo" review
    fi
}

main(){
    # Find all repos that contain changes #
    for repo in $(find "$path" -name "*.git"); do
	# Remove last 4 chars: Path should look like .../parentDir/childDir/.git
        repo=${repo::-4}

	# Verify string ends in a dir: Otherwise .repo/projectName.git causes trouble
	if [ ${repo: -1} != "/" ]; then
            continue
	fi

        diff=$(git -C "$repo" status | grep "Changes")

        # If repo contains changes #
        if [ "$diff" != "" ]; then
            echoFiles

            # ~~~ Review ~~~ #
            if [ "$review" -eq 1 ]; then
                # Ask user to review files #
		REPLY=$(getBtnPress "Review files in $repo? Y/n/s(kip): ")
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    reviewFiles
                elif [[ $REPLY =~ ^[Ss]$ ]]; then
                    continue
                fi
            fi

            # ~~~ Commit ~~~ #
            if [ "$commit" -eq 1 ]; then
		# Ask user to stage files
		REPLY=$(getBtnPress "Stage changes in $repo? Y/n: ")
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
                    addFiles
                fi
		# Ask user to commit files
		REPLY=$(getBtnPress "Commit changes in $repo? Y/n: ")
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
                    commitChanges
                fi
		# Ask user to upload commit
		REPLY=$(getBtnPress "Upload commit in $repo? Y/n: ")
	        if [[ $REPLY =~ ^[Yy]$ ]]; then
                    uploadCommit
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
