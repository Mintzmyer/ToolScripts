# GittingBetter

This directory contains scripts that help to improve
workflows, automate tasks, and improve work quality
as it pertains to:
- Various elements of source control
- Manipulating large repositories of source code
- Leveraging Git, TDD and TCR workflows

They were mostly created in response to an area I
sought to optimize, and many earned coveted points
as 'Quick and Easy Kaizens'

###### Auto-Generated Documentation
### generateReadmeFromHeader.cpp
 This file updates a README.md file with the header
  block comments of the files it is fed. 
 
  Calling it with just a directory erases the README.md file
  after a tag marking the auto-generated portion 
  (allowing for static overarching directory comments
  to remain untouched)
  
  Passing it files lets it extract and append their
  headers to the README.md file
 
  It is implemented in C++ with the hope that it is
  OS agnostic, and has an accompanying shell script
  to invoke it in a linux/unix environment. A similar
  batch file would permit it to run on Windows
 
### generateReadmeFromHeader.sh
 This script performs the linux/unix specific work
     of feeding files to the readmeGenerator

### review.sh
 This script is intended to review and commit changes to large projects
     which have multiple git repositories, and a particular feature or fix
     might touch multiple parts of the source code

 It helps users leverage version control tools like reviewing all changes
     and commit multiple related changesets in separate repos

 It gives a birds-eye view of changes and prevents partial checkins

### save.sh
 This script automates the process of stashing changes,
     essentially creating a checkpoint throughout the
     multiple repos a change might touch. This allows
     for easier mobility and "save points" between 
     sections of work.
### sync.sh
 This script automates the sync functionality, making it
     easier to stay up to date with everyone's changes,
     even if they touch source that you're not currently
     working on or even thinking about.

### testANDcommitORrevert.sh
 This script implements an idea by Oddmund Strømmer, 
     and popularized by Kent Beck, described here:
     https://medium.com/@kentbeck_7670/test-commit-revert-870bbd756864
     which I first heard about on HanselMinutes podcast here:
     https://player.fm/series/hanselminutes-fresh-talk-and-tech-for-developers/test-commit-revert-with-kent-beck

 'Test && Commit || Revert' is a workflow that seeks to 1up "Limbo On The Cheap"s
     'Test && Commit' by strongly encouraging programmers to make as small,
     incremental changes as possible...because if their tests fail their changes
     are reverted and lost! This reduces Sunk Cost Fallacy waste.

 This script's intention is to make a generic impelementation of the workflow
     so that it's all ready to experiment with when I have the opportune project
