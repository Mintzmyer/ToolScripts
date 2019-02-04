# GerritCaret

This directory contains scripts that leverage Gerrit's SSH API
and HTTP REST API. They add and augment Gerrit's functionality
in particular automating:
- Gerrit review process
- Gerrit inline comments

They touch on just some of the functionality Gerrit exposes
through the SSH and HTTP interfaces.

###### Auto-Generated Documentation
### Plus2.sh

 When software engineer coworkers create a new build for testing or release
     a script auto-generates a new branch for that build. It is checked into
     Gerrit, where all commits are reviewed before merged on consensus. 

 Because all branches are auto-generated, they don't really need to be peer
     reviewed. To learn about the Gerrit command line interface, and to play
     a small practical joke, I wrote a script to approve any new branches
     within 3 seconds of being committed. We'll see how long it takes people
     to notice that I'm reviewing new branches faster than humanly realistic
### reviewChecklist.py

 This program intends to leverage Gerrit's REST API to automatically
     add inline comments to new commits

 Specifically, SW's process improvement meetings are formalizing
     a review guidelines document of best practices, gotchas, and
     coding standards to use in Gerrit's peer reviews. To better
     integrate this list into the workflow, I am hoping to auto-
     post the checklist as inline comments on the Commit Message
     which reviewers can then mark as 'Done'

 Hopefully, this creates visibility for the rest of the team about
     what items haven't been verified and helps utilize the
     Review Checklist into our workflow
### reviewChecklist.txt
Testing ntoe
*note

