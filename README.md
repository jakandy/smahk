# SuperMemo AHK
A collection of AutoHotkey scripts to be used with SuperMemo.
These scripts automates the user interface of SuperMemo using the open-source
scripting language AutoHotkey.

## Installation
1) Install AutoHotkey v2 (https://www.autohotkey.com/)
2) Download and extract all files from this repository into any directory
3) Run "smahk.ahk"

The first time running the script you will be prompted to specify the file
path for: the SuperMemo executable and the executable for the web browser you want to use for web imports.
The paths can be changed manually after installation by editing "smahk-settings.ini".

Be aware that only one collection can be used for each smahk installation.
To use smahk with several collections you will therefore need to install
it several times in separate directories.

To uninstall smahk, simply delete the script files.

## Usage
Run "smahk.ahk" when you want to start SuperMemo AHK. Your SuperMemo installation is not modified so you can still launch SuperMemo without AHK by running its executable like normal.

When both the script and SuperMemo is running, press any of the below hotkeys to perform the associated action.

Closing SuperMemo will automatically terminate the smahk script.

### General hotkeys (can be invoked from any application):
- Ctrl-Alt-X: Extract text or image into new child topic
- Ctrl-Shift-X: Extract text or image into previous topic
- Alt-Shift-X: Extract text or image into current topic
- Alt-Esc: Terminate smahk script
- Shift-Esc: Reload smahk script

### Browser hotkeys:
- Ctrl-Alt-I: Show GUI for importing web article

### SuperMemo hotkeys:
- Alt-0-9: Change priority of current element within certain range
- Ctrl-Alt-Middleclick: Open a hyperlink in web browser
- Ctrl-Alt-O: Create image occlusion item
- Ctrl-Alt-N: Create new child topic
- Ctrl-Alt-C: Show GUI for concept options
- Ctrl-Alt-Enter: Mark the current element
- Ctrl-Alt-Backspace: Go to marked element
- Ctrl-Alt-f12: Backup collection

## Tested with
- SuperMemo, version 18.05
- AutoHotkey, version 2.0.2
- Mozilla Firefox, version 102.9.0esr (64-bit)
- Windows 10

## Terms of use
Copyright (C) 2023 andyjak

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.