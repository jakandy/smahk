# SuperMemo AHK
A collection of AutoHotkey scripts for using with SuperMemo

# Description
This script automates the UI of SuperMemo using the open-source
scripting language AutoHotkey.
The script is a "master script", meant to be running concurrently
with SuperMemo. When the user presses a particular hotkey (see the
"Usage" section below), this script calls a certain function. The function
then executes its task and returns to this script again. If the user
closes SuperMemo, the script is automatically terminated.
It is meant to be software-agnostic, meaning you can use it with any web
browser or reader application. However, that does not guarantee that it
will always work for every application. Feel free to edit this script
to better suit your needs.

# Installation
exe: Extract smahk.exe into any directory and run it.
ahk: Extract all ahk files in any directory and run smahk.ahk
   (requires AutoHotkey v2 to be installed).
Be aware that only one collection can be used for each smahk installation.
To use smahk with several collections you will therefore need to install
smahk several times in separate directories.
The first time running the script you will be prompted to specify the file
path for: SuperMemo and the web browser you want to use for web imports.
The paths can also be changed manually by editing smahk-settings.ini.
You may get a warning from your anti-virus if you run "smahk.exe" but it is
just a false positive. If you're still worried about it, then you can
use the ahk-version instead.

# Usage
While the script and SuperMemo is running, press any of the below hotkeys to
perform the associated action.

  General hotkeys (can be invoked from any application):
  - Ctrl-Alt-X: Extract text or image into new topic
  - Ctrl-Shift-X: Extract text or image into previous topic
  - Alt-Shift-X: Extract text or image into current topic
  - Alt-Esc: Terminate script
  - Shift-Esc: Reload script

  Browser hotkeys:
  - Ctrl-Alt-I: Show GUI for importing web article

  SuperMemo hotkeys:
  - Alt-0-9: Change priority of current element within certain range
  - Ctrl-Alt-Middleclick: Open a hyperlink in web browser
  - Ctrl-Alt-O: Create image occlusion item
  - Ctrl-Alt-N: Create new child topic
  - Ctrl-Alt-C: Show GUI for concept options
  - Ctrl-Alt-Enter: Mark the current element
  - Ctrl-Alt-Backspace: Go to marked element

# Tested with
- SuperMemo, version 18.05
- AutoHotkey, version 2.0.2
- Windows 10

# Terms of use
  Copyright (C) 2023 andyjak
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTYwithout even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.