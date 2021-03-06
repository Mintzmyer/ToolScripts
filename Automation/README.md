# Automation

This directory contains scripts that help to improve
workflows, automate tasks, and improve work quality
as it pertains to:
- Device reprogramming
- Physical device testing
- Repetitive execution of commands

Though some are obsolete, they were created in response
to an area I sought to optimize, and many earned coveted
points as 'Quick and Easy Kaizens'

###### Auto-Generated Documentation
### RebootTester.sh

 This script is intended to automate testing of an Android device's boot 
     process by observing the print statements from the start up sequence
     
 It presumes that the failure condition causes the device to crash
     thus it only restarts if the device boot succeeds

 This script listens in to a serial port, presumably being fed RS232
     or equivalent, from the device

 This script is written to be light-weight and modifiable, rather than
     covering all or many of the use cases with fleshed out flag options
### sedsdead.sh

 This script is intended to perform a recursive search and replace
     for files and directories, and/or file contents much like 
     vim's (sed) %s/search/replace/gc for a single file
 
 This is useful in large projects when a naming convention or
     new standard needs to be implemented across the board
### uparrow.sh

 This script is intended to rapidly automate a process on-the-fly
     by letting the user select from recent command history and
     then run that subset of commands repeatedly

 It separates each command execution by a keystroke from the user

 This is ideal for situations where a process is repetitive, but
     dynamic. In cases that do not quite warrant their own script,
     it removes up-arrowing or reverse-searching through history
     over and over again. A dynamic hotkey.
