; Title:
;   SuperMemo AHK - Search module
;
; Version:
;   1.0.1, 08/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   search for an element in the collection from outside SuperMemo.
;   It is meant to be run using an application launcher, e.g. Keypirinha.
;
; Usage:
;   This script takes in a string as a command line argument, for example:
;   smahk-Search.ahk "search string"
;   or
;   smahk-Search.ahk search string
;   An application launcher can then be set up to launch this script
;   with a custom search command. Read the docs of your application launcher
;   on how to do this.
;   
; Test setup:
;   - SuperMemo, version 18.05
;   - AutoHotkey, version 2.0.2
;   - Keypirinha, version 2.26
;   - Windows 10
;
; Terms of use:
;   Copyright (C) 2023 andyjak
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;

#Requires AutoHotkey v2.0
#Include "smahk-lib.ahk"

; ******************************************************************************
; ************************************* FUNCTIONS ******************************
; ******************************************************************************

; Function name: parseCmdArg
; --------------------
;
; Description:
;   Parses the command line arguments and turns it into a string.
;
; Input parameter:
;   ---
;
; Return:
;   string - variable containing the arguments
;
parseCmdArg()
{
    string := ""
    for i, param in A_Args
        string := string . " " . param
    string := SubStr(string, 2)
    return string
}

; Function name: findElement
; --------------------
;
; Description:
;   Searches the current SM collection for the element in the string.
;   By default selects the "Match whole word" checkbox to find more
;   relevant search results.
;
; Input parameter:
;   string - variable containing the search string
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
findElement(string, smPID)
{
    ; Switch to SM
    safeActivateElementWindow(smPID)

    Send("^{f}")
    WinWaitActive("ahk_class TMyFindDlg")
    Send("{del}")

    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    A_Clipboard := string
    
    if (safeCopyToClipboard(string) == -1)
    {
        MsgBox("Unable to transfer search string to A_Clipboard.", "Error!", 0)
        return
    }

    safePasteText()
    Send("!{w}")                              ; select match whole word
    Send("{enter}")

    ; Restore clipboard
    WinWaitNotActive("ahk_class TMyFindDlg")
    A_Clipboard := ClipSaved
    ClipSaved := ""
    return
}