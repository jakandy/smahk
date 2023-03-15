; Title:
;   SuperMemo AHK - Search module
;
; Version:
;   v1.00, 03/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   search for an element in the SuperMemo collection.
;   It is meant to be run using an application launcher, e.g. Keypirinha.
;
; Usage:
;   Place this file in the same directory as the other files for smahk.
;   Run this script with your search string as command arguments, ex:
;   smahk-Search.ahk "search string"
;   or
;   smahk-Search.ahk search string
;   
; Tested with:
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
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#SingleInstance ignore
SetKeyDelay(0, 10)
#Include "smahk-lib.ahk"         ; Custom subroutines used in the script.

searchstring := parseCmdArg()

if (searchstring == "")
{
    MsgBox("Empty search string.", "Error!", 0)
    ExitApp()
}

; Supermemo settings
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if (smProcessName == "ERROR")
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

; Start SM unless already running
if ( WinExist("ahk_exe " . smProcessName) == 0 )
{
    Run("..\smahk.ahk")
    WinWaitActive("ahk_exe " . smProcessName)
    smPID := WinGetPID("ahk_exe " . smProcessName)
}
else
{
    smPID := WinGetPID("ahk_exe " . smProcessName)
}

findElement(searchstring, smPID)
ExitApp()

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