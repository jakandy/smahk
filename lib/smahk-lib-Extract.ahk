; Title:
;   SuperMemo AHK - Extract module
;
; Version:
;   1.0.1, 08/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It is a library containing functions to
;   extract text or images from different sources and import them into SuperMemo.
;
; Usage:
;   Place this file in the same directory as "smahk-lib.ahk" and include it
;   to your script using the #include directive. After that you can call
;   any function as normal.
;   Please read the header of each function for more info about what they do and
;   how to use them.
;
; Test setup:
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
; Function name: anyExtract
; --------------------
;
; Description:
;   Makes an "extract" by copying a highlighted text selection from an application,
;   duplicates the current element in SuperMemo, clears its contents and
;   pastes the extracted text there. If no text has been highlighted,
;   Windows snipping tool will start and prompt the user to draw a rectangle
;   on the screen. When the user has done that, a topic containing an image
;   will be created.
;
; Input parameter:
;   target - integer, set to 0 if creating new extract, 1 if appending
;            to previous extract and 2 if appending to current extract
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
anyExtract(target, smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    safeCopyToClipboard("", 10000)
    
    ; Copy selection
    Send("^{c}")
    
    if !ClipWait(1, 0)
    {
        ; User has not made a text selection, start snipping tool
        Send("#+{s}")
        WinWaitActive("ahk_exe ScreenClippingHost.exe")
        Sleep(50)
        WinWaitNotActive("ahk_exe ScreenClippingHost.exe")

        if !ClipWait(1, 1)
        {
            ; User has aborted image clip
            A_Clipboard := ClipSaved
            ClipSaved := ""
            Return
        }
        else
        {
            ; User has made an image clip
            imageExtract := true
        }
    }
    else
    {
        ; User has made a text selection
        imageExtract := false
        
    }
    
    ; Window switch to SM
    safeActivateElementWindow(smPID)
    
    if (target == 0)
    {
        ; create new extract
        newChildReturnCode := createNewChildTopic(true, smPID)
        if (newChildReturnCode == -1)
            return
    }
    else
    if (target == 1)
    {
        ; append to previous element
        prevEl := WinGetTitle("A")
        Send("!{left}")
        WinWaitNotActive(prevEl)
        moveCursorToEnd(smPID)
    }
    else
    if (target == 2)
    {
        ; append to current element
        prevEl := WinGetTitle("A")
        Send("!{left}")
        WinWaitNotActive(prevEl)
        prevEl := WinGetTitle("A")
        Send("!{right}")
        WinWaitNotActive(prevEl)
        moveCursorToEnd(smPID)
    }
    else
    {
        MsgBox("Target argument has to be 0, 1 or 2", "Error!", 0)
        A_Clipboard := ClipSaved
        ClipSaved := ""
        Return
    }
    Sleep(100)
    
    ; TODO: fix so it works with element with image component
    if (imageExtract == false)
    {
        ; paste text
        safePasteText()
    }
    else
    if (imageExtract == true)
    {
		if (target == 0)
        {
            ; set template
            Send("Extracted image")
			Send("^+{m}")
            WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID)
            Send("article picture")
            Send("{enter}")
            
            WinWaitNotActive("ahk_class TRegistryForm ahk_pid " smPID)
            WinWaitActive("ahk_class TElWind ahk_pid " smPID)
            
            ; paste image
            Send("^{v}")
            WinWaitActive("ahk_class TInputDlg ahk_pid " smPID)
            Send("{Enter}")
            WinWaitNotActive("ahk_class TInputDlg ahk_pid " smPID)
        }
        else
        if ( (target == 1) OR (target == 2) )
        {
            ; paste image
            Send("^{v}")
            WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID)
            Send("{enter}")
            while ( (WinActive("ahk_class TChoicesDlg") == 0) AND (WinActive("ahk_class TMsgDialog") == 0) )
                Sleep(50)
            Send("{enter}")
            WinWaitActive("ahk_class TInputDlg ahk_pid " smPID)
            Send("{enter}")
            WinWaitNotActive("ahk_class TInputDlg ahk_pid " smPID)
        }
    }
    else
    {
        MsgBox("Could not determine if a text or image extract was made.", "Error!", 0)
        A_Clipboard := ClipSaved
        ClipSaved := ""
        Return
    }
    
    if (target != 2)
    {
        ; go to parent
        prevEl := WinGetTitle("A")
        Send("^{up}")
        WinWaitNotActive(prevEl)
    }
    
    ; switch back to application
    Send("!{tab}")
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return
}

