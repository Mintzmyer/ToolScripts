# SourceControl

This directory contains scripts that help to improve
workflows, automate tasks, and improve work quality
as it pertains to various elements of source control,
large repositories of source code, and git.

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

### Plus2.sh
 When software engineer coworkers create a new build for testing or release
     a script auto-generates a new branch for that build. It is checked into
     Gerrit, where all commits are reviewed before merged on consensus. 

 Because all branches are auto-generated, they don't really need to be peer
     reviewed. To learn about the Gerrit command line interface, and to play
     a small practical joke, I wrote a script to approve any new branches
     within 3 seconds of being committed. We'll see how long it takes people
     to notice that I'm reviewing new branches faster than humanly realistic
### review.sh
 This script is intended to review and commit changes to large projects
     which have multiple git repositories, and a particular feature or fix
     might touch multiple parts of the source code

 It helps users leverage version control tools like reviewing all changes
     and commit multiple related changesets in separate repos

 It gives a birds-eye view of changes and prevents partial checkins

### rmSpace.sh
 This script automates renaming files. Sometimes, there's
     a bunch of files with spaces or other annoying chars
     and this script can be easily updated to pull out
     spaces and other unseemly naming conventions

### save.sh
 This script automates the process of stashing changes,
     essentially creating a checkpoint throughout the
     multiple repos a change might touch. This allows
     for easier mobility and "save points" between 
     sections of work.
### sedsdead.sh
 This script is intended to perform a recursive search and replace
     for files and directories, and/or file contents much like 
     vim's (sed) %s/search/replace/gc for a single file
 
 This is useful in large projects when a naming convention or
     new standard needs to be implemented across the board
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
