# ToolScripts
A variety of handy bash scripts written to automate (Android/embedded Linux) development

Brief documentation explaining their intention and useage is included with each script source.

## Automation    - Scripts that automate/streamline repetitive motion, including Gerrit
- Plus2.sh            - Cheeky script that reviews auto-generated branches in Gerrit
- RebootTester.sh     - Cycles boot sequence, searching logcat for success/fail conditions
- reviewChecklist.py  - Automatically adds inline comments to a Gerrit commit review
- sedsdead.sh         - Propogates naming/format change through dirs/files/file contents
- uparrow.sh          - "Hotkey" a set of commands on-the-fly, skip ctrl-Ring/up arrowing

## GittingBetter - Scripts that leverage Git to improve workflows
- generateReadmeFromHeader.cpp  - Takes file, extracts header comment, prints to README
- generateReadmeFromHeader.sh   - CLI and gathers files to pass to .cpp in Unix environments
- review.sh                     - Manages review/commits when a chance involves multiple repos
- rmSpace.sh                    - Formats space out of file/directory names recursively
- save.sh                       - Saves off a progress checkpoint in all repos, can leave stashed
- sync.sh                       - Syncs all git repos and AOSP builds to keep remote up-to-date
- testANDcommitORrevert.sh      - Implements TDD scaffolding that commits or reverts on testing
