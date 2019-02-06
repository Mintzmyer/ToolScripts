#!/usr/bin/env python3
#
# This program intends to leverage Gerrit's REST API to automatically
#     add inline comments to new commits
#
# Specifically, SW's process improvement meetings are formalizing
#     a review guidelines document of best practices, gotchas, and
#     coding standards to use in Gerrit's peer reviews. To better
#     integrate this list into the workflow, I am hoping to auto-
#     post the checklist as inline comments on the Commit Message
#     which reviewers can then mark as 'Done'
#
# Hopefully, this creates visibility for the rest of the team about
#     what items haven't been verified and helps utilize the
#     Review Checklist into our workflow


# Thanks to this little gem, I finally stopped trying to authenticate
#     with OpenID and used the HTTP API authentication. *Face palm*
# https://softwarefactory-project.io/docs/faqs/gerrit_rest_api.html

from pygerrit2 import GerritRestAPI, HTTPBasicAuth, GerritReview
import os
import time

DEBUG = False

# Verbose print function for debugging
def vprint(output):
    if DEBUG:
        print(output)

### Class to manage fetching the review guidelines checklist into JSON ###
class ChecklistGenerator:

    def __init__(self, checklistFile):
        # Get Review Guidelines checklist
        scriptPath = os.path.dirname(os.path.abspath( __file__ ))
        guideFilepath = os.path.expanduser(scriptPath+"/"+checklistFile)
        if os.path.isfile(guideFilepath) == False:
            print("Error: No checklist file named <"+checklistFile+"> found")
            vprint(scriptPath)
            quit()

        with open(guideFilepath, 'r') as guideFile:
            checklist = []
            for line in guideFile.readlines():
                line = line.rstrip("\n\r")
                checklist.append(line)
            self.checklist = checklist

        self.review = GerritReview()
        self.getChecklistComments(self.checklist)

    # Converts it to GerritReview for the Gerrit REST API
    def getChecklistComments(self, checklist):
        comments = []
        for check in checklist:
            comment = {"filename": "/COMMIT_MSG", "line": 6}
            comment["message"]=check
            comments.append(comment)
        self.review.add_comments(comments)
        vprint(comments)

    # Returns GerritReview object of Review Checklist for posting as inline comments
    def getReview(self):
        return self.review

### Class to encompass connecting to and calling Gerrit's REST API ###
class RestAPI:

    def __init__(self, credentialsFile, gerritUrl):
        # Get Login Authentication information
        # This expects a file that contains only a Gerrit user's
        # <Username> <HTTP Password>
        # Currently, this is found on Gerrit, select:
        # -> Your username dropdown 
        # -> Settings
        # -> HTTP Password
        scriptPath = os.path.dirname(os.path.abspath( __file__ ))
        authFilepath = os.path.expanduser(scriptPath + "/" + credentialsFile)
        if os.path.isfile(authFilepath) == False:
            print("Error: No authentication file named "+credentialsFile+" found")
            vprint(scriptPath)
            quit()
    
        with open(authFilepath, 'r') as loginFile:
            line = loginFile.readline()
            login = line.split()
            if len(login) < 2:
                print("Error: Insufficient login credentials")
                quit()
            user = login[0]
            password = login[1]
    
        auth = HTTPBasicAuth(user, password)
    
        self.rest = GerritRestAPI(url=gerritUrl, auth=auth)

    # Wrapper for GerritRestAPI's GET method
    def get(self, query):
        result = self.rest.get(query, headers={'Content-Type': 'application/json'})
        return result

    # Wrapper for GerritRestAPI's review method
    def review(self, changeID, revision, review):
        result = self.rest.review(changeID, revision, review)
        return result

### Class to encapsulate Gerrit functionality pipelines ###
class GerritDaemon:

    def __init__(self, rest, gerritReview):
        self.rest = rest
        self.review = gerritReview
        # Default behavior is to only add Review Checklist to
        # new commits, not each new patch
        self.recommentNewPatches = False

    # Set Daemon to append checklist to every new patch (True) or
    #     just once at the initial commit (False, default)
    def checklistEveryPatch(self, TorF):
        self.recommentNewPatches = TorF

    # Daemon to seek new commits, and add Review Checklist comment
    def checklistDaemon(self):
        while True:
            newCommits = self.findNewCommits()
            for commit in newCommits:
                self.addChecklist(commit)
            time.sleep(3)

    # Finds all open commits and calls isUncommented to check for newness
    def findNewCommits(self):
        getOpenCommits = "/changes/?q=status:open"
        openCommits = self.rest.get(getOpenCommits)
        newCommits = []

        for commit in openCommits:
            cID = commit['change_id']
            subj = commit['subject']
            vprint(subj + "  => " + cID)
            if self.isUncommented(cID):
                newCommits.append(cID)
            vprint("==============================")
        return newCommits

    # Checks if the commit has comments or is brand new
    def isUncommented(self, changeID):
        # Checks if the current patch has any comments
        if self.recommentNewPatches:
            getComments = "/changes/"+changeID+"/revisions/current/comments"
        # Checks if the entire commit has any comments
        else:
            getComments = "/changes/"+changeID+"/comments"

        allComments = self.rest.get(getComments)
        vprint(not allComments)
        return not allComments

    # Adds Review Checklist to the commit with given ID
    def addChecklist(self, commitID):
        result = self.rest.review(commitID, "current", self.review)
        vprint(result)


### Main method ###

# Open the Review Checklist and load it into a Gerrit Review class object
checklist = ChecklistGenerator('reviewChecklist.txt')

# Connect to Gerrit via the Gerrit Rest API class
connect = RestAPI('.credentials.txt', 'http://gerrit.rosenaviation.com:8080')

# Initialize the Daemon with the Gerrit connection and the Review Checklist
daemon = GerritDaemon(connect, checklist.getReview())


# Run daemon to append checklist once to new commits, not each patch
daemon.checklistEveryPatch(False)
# Start the daemon
daemon.checklistDaemon()

