#!/bin/bash
#
# When software engineer coworkers create a new build for testing or release
#     a script auto-generates a new branch for that build. It is checked into
#     Gerrit, where all commits are reviewed before merged on consensus. 
#
# Because all branches are auto-generated, they don't really need to be peer
#     reviewed. To learn about the Gerrit command line interface, and to play
#     a small practical joke, I wrote a script to approve any new branches
#     within 3 seconds of being committed. We'll see how long it takes people
#     to notice that I'm reviewing new branches faster than humanly realistic

# Here, my ~/.ssh/config file looks something like:
# Host gerrit
#   Hostname <gerrit_url>
#   Port <gerrit_port>
#   User <my_username>
#
#

newBranchSubj="<The subject auto-generated for all new branches>"
myUsername="<my_username>"

getCommitIds(){
    results=$(ssh gerrit gerrit query status:open \
	    --commit-message --all-approvals --current-patch-set \
	    | grep -A 2 "currentPatchSet" | grep "revision" | tr -s ' ')

    # Parse out the "revision: " formatting
    results=${results//revision: /}

    # Return string of space-separated commit ids
    echo "$results"
}

autoApprove(){
    # Traverse latest patchset revision and save revision
    commitIds=$(getCommitIds)

    for commit in $commitIds; do
        subj=$(ssh gerrit gerrit query commit:"$commit" --commit-message \
		| grep "subject")

        # If commit is new branch...
        if [[ "$subj" =~ $newBranchSubj ]]; then

                # Check if no one has approved the change yet
        	plus2=$(ssh gerrit gerrit query --all-approvals commit:"$commit" \
			| grep -A 3 "approvals" | grep "value")

		author=$(ssh gerrit gerrit query commit:"$commit" \
			| grep -A 3 "owner" | grep "username" | grep "$myUsername")

        	# If no one has approved the new branch yet, and it's not my branch
		#     +2 it. It gets auto-generated, it's probably great
        	if [ "$plus2" == "" ] && [ "$author" == "" ]; then
                ssh gerrit gerrit review --code-review +2 "$commit"
                echo "+2 $subj"
	        #  ssh gerrit gerrit query commit:"$commit" \
		#	--commit-message --all-approvals
            fi
        fi
    done;
}


while true; do
    # Approve any new branches
    autoApprove

    # Sleep for 3 seconds
    sleep 3
done
