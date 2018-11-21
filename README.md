# ToolScripts
A variety of handy bash scripts written to automate (Android/embedded Linux) development

Brief documentation explaining their intention and useage is included with each script source.

## Automation    - Scripts that automate/streamline repetitive motion
- RebootTester.sh - Cycles boot sequence, searching logcat for success/fail conditions
- ff.sh           - Makes and flashes AOSP build
- otg.sh          - Sets USB to On-The-Go mode to install apks/pull data (bit outdated)
- uparrow.sh      - "Hotkey" a set of commands on-the-fly, skip ctrl-Ring/up arrowing

## SourceControl - Scripts that improve management of source code
- Plus2.sh        - Cheeky script that reviews auto-generated branches
- review.sh       - Manages review/commits when a chance involves multiple repos
- rmSpace.sh      - Formats space out of file/directory names recursively
- save.sh         - Saves off a progress checkpoint in all repos, can leave stashed
- sedsdead.sh     - Propogates naming/format change through dirs/files/file contents
- sync.sh         - Syncs all git repos and AOSP builds to keep remote up-to-date
