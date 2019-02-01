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

from pygerrit2 import GerritRestAPI, HTTPBasicAuth
from requests_oauthlib import OAuth2
import os
import json
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
            print("Error: No "+checklistFile+" file found")
            quit()

        with open(guideFilepath, 'r') as guideFile:
            checklist = []
            for line in guideFile.readlines():
                line = line.rstrip("\n\r")
                checklist.append(line)
            self.checklist = checklist

        self.getChecklistJSON(self.checklist)

    # Converts it to JSON for the Gerrit REST API
    def getChecklistJSON(self, checklist):
        opening = '{\
    "comments": {\
      "/COMMIT_MSG": ['
        closing = '      ]\
    }\
}'
        jsonStr = opening
        first = True
        for check in checklist:
            if first:
                first = False
                comment = '\
        {\
          "line": 0,\
          "message": "'+check+'"\
        }'
            else:
                comment = ',\
        {\
          "line": 0,\
          "message": "'+check+'"\
        }'
            jsonStr += comment
        jsonStr += closing
        try:
            json.loads(jsonStr)
        except ValueError as error:
            print("Error: Failed to generate valid JSON")
            print(error)
            vprint(jsonStr)
            quit()

        self.jsonChecklist = jsonStr

    # Returns JSON of Review Checklist for posting as inline comments
    def getJSON(self):
        return self.jsonChecklist

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
        result = self.rest.get(query)
        return result

    # Wrapper for GerritRestAPI's POST method
    def post(self, query, jsonArgs):
        result = self.rest.post(query, json=jsonArgs)
        return result

### Class to encapsulate Gerrit functionality pipelines ###
class GerritDaemon:

    def __init__(self, rest, jsonStr):
        self.rest = rest
        self.jsonStr = jsonStr

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
        getAllComments = "/changes/"+changeID+"/comments"
        allComments = self.rest.get(getAllComments)
        vprint(not allComments)
        return not allComments


    def addChecklist(self, commitID):
        postChecklist = "/changes/" + str(commitID) + "/revisions/current/review"
        vprint(postChecklist +" "+ self.jsonStr)
        result = self.rest.post(postChecklist, self.jsonStr)

    # Test to add inline comments to just one commit
    def test(self):
        newCommits = self.findNewCommits()
        if newCommits:
            self.addChecklist(newCommits[0])


# Main method
checklist = ChecklistGenerator('reviewChecklist.txt')

connect = RestAPI('.credentials.txt', 'http://gerrit.rosenaviation.com:8080')

daemon = GerritDaemon(connect, checklist.getJSON())

# Run test sparingly or you'll use up the available commits
#daemon.test()

# Run daemon to append checklist to new commits
#daemon.checklistDaemon()

'''
newCommits = findNewCommits()

for commit in newCommits:
    print(commit)
    addChecklist(commit, reviewList)
#vprint(parsedCommits)

def listFiles(changeID):
    getFiles = "/changes/"+changeID+"/revisions/current/files"
    allFiles = rest.get(getFiles)
    #vprint(allFiles)



change_id = "521627"
cur_rev = "3"

query = "/changes/" + str(change_id) + "/revisions/" + str(cur_rev) + "/review"

#changes = rest.get(query)
changes = rest.post(query, json={
    "labels": {
        "Code-Review": +2
    }
})


# changes = rest.get("/changes/?q=status:open")
vprint(changes)

vprint("Done")
"""
'''
