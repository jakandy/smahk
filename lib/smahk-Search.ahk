; Title:
;   SuperMemo AHK - Search module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   This script searches for an element in your current SuperMemo collection.
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
;   - SuperMemo 18.05
;   - AutoHotkey, version 2.0.2
;   - Windows 10
;
; Terms of use:
;   This script was created for personal use, so it is not tested or optimized
;   on other systems.
;   The author is not responsible for any unintentional harm to your
;   SuperMemo collection or computer. Use at your own risk!
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