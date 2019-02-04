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

DEBUG = True

def vprint(output):
    if DEBUG:
        print(output)

### Class to manage fetching the review guidelines checklist into JSON ###
class ChecklistGenerator:

    def __init__(self, checklistFile):
        # Get Review Guidelines checklist
        guideFilepath = os.path.expanduser(checklistFile)
        if os.path.isfile(guideFilepath) == False:
            print("Error: No checklist file named <"+checklistFile+"> found")
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
        authFilepath = os.path.expanduser(credentialsFile)
        if os.path.isfile(authFilepath) == False:
            print("Error: No authentication file named "+credentialsFile+" found")
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

    # Wrapper for GerritRestAPI's POST method
    def post(self, query, jsonArgs):
        result = self.rest.post(query, json={**jsonArgs}) 
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
        self.recommentNewPatches = False

    def checklistEveryPatch(self, TorF):
        self.recommentNewPatches = TorF

    def checklistDaemon(self):
        while True:
            newCommits = self.findNewCommits()
            for commit in newCommits:
                self.addChecklist(commit)
            time.sleep(3)

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

    def isUncommented(self, changeID):
        if self.recommentNewPatches:
            getComments = "/changes/"+changeID+"/revisions/current/comments"
        else:
            getComments = "/changes/"+changeID+"/comments"

        allComments = self.rest.get(getComments)
        vprint(not allComments)
        return not allComments


    def addChecklist(self, commitID):
        result = self.rest.review(commitID, self.review)
        vprint(result)


# Main method
checklist = ChecklistGenerator('reviewChecklist.txt')

connect = RestAPI('.credentials.txt', 'http://gerrit.rosenaviation.com:8080')

daemon = GerritDaemon(connect, checklist.getReview())


# Run daemon to append checklist to new commits
#daemon.checklistEveryPatch(False)
#daemon.checklistDaemon()

