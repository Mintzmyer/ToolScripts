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


# Public API calls work great, but I'm still having trouble
# authenticating which prevents me from posting inline comments

from pygerrit2 import GerritRestAPI, HTTPBasicAuth

rest = GerritRestAPI(url='http://gerrit.rosenaviation.com:8080')


change_id = "521627"
cur_rev = "3"

query = "/changes/" + str(change_id) + "/revisions/" + str(cur_rev) + "/review"

changes = rest.get(query)
'''
changes = rest.post(query, json={
    "labels": {
        "Code-Review": +2
    }
})
'''


# changes = rest.get("/changes/?q=status:open")
print(changes)

print("Done")

