; Title:
;   SuperMemo AHK - Mark and Recall module
;
; Version:
;   v1.0.0, 03/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It is a library containing functions to
;   save the number of an element (mark) that you want to come back to later (recall).
;   (Yes, it is named after the magic spell from TES III: Morrowind ;) )
;
; Usage:
;   Place this file in the same directory as "smahk-lib.ahk" and include it
;   to your script using the #include directive. After that you can call
;   any function as normal.
;   Please read the header of each function for more info about what they do and
;   how to use them.
;
; Tested with:
;   - SuperMemo, version 18.05
;   - AutoHotkey, version 2.0.2
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
; Function name: markElement
; --------------------
;
; Description:
;   Returns the number (integer) of the current element.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   markedElement - the number of the element to mark
;
markElement(smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    
    safeActivateElementWindow(smPID)
    Send("^{g}")
    WinWaitActive("ahk_class TInputDlg")
    Send("^{c}")
    
    if !ClipWait(1, 0)
    {
        ; Unable to get element number
        markedElement := ""
    }
    else
    {
        markedElement := A_Clipboard
        Send("{Esc}")
        WinWaitNotActive("ahk_class TInputDlg")
    }
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return markedElement
}

; Function name: recallElement
; --------------------
;
; Description:
;   Navigates to a certain element using its element number.
;
; Input parameter:
;   elementnr - the number of the element
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
recallElement(elementnr, smPID)
{
    safeActivateElementWindow(smPID)
    Send("^{g}")
    WinWaitActive("ahk_class TInputDlg")
    
    Send(elementnr)
    Send("{Enter}")
    WinWaitNotActive("ahk_class TInputDlg")
    
    Return
}