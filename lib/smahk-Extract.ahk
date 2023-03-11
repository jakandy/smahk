; Title:
;   SuperMemo AHK - Extract module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   This file contains functions that can be used when
;   extracting from different sources and import into SuperMemo.
;   Many functions here uses the PostMessage function and some
;   wParam argument values changes between SuperMemo versions. 
;   This means that most functions will probably only work for the
;   version of SuperMemo listed in the requirements section below.
;   To update the functions for other versions, new wParam values need to
;   be found using a software like Spy++.
;
; Usage:
;   Place this file in the same folder as the script you want to use.
;   Add at the top of your script: "#Include smahk-lib.ahk" without quotes.
;   Call any function in this library like any other function, i.e. 
;   functionName(argument). Read the header of each function for more info
;   about what they do and how to use.
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
#Include "smahk-lib.ahk"         ; Custom subroutines used in the script.
; TODO: add timeouts to all winwait

; Function name: anyExtract
; --------------------
;
; Description:
;   Makes an "extract" by copying a text selection from an application,
;   duplicates the current element in SuperMemo, clears its contents and
;   pastes the extracted text there.
;
; Input parameter:
;   target - integer, set to 0 if creating new extract, 1 if appending
;            to previous extract and 2 if appending to current extract
;   highlightKey - string that contains the keyboard shortcut for highlighting
;                  the text during extract. Set to "" if no highlighting.
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
anyExtract(target, highlightKey, smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    safeCopyToClipboard("", 10000)
    
    ; Copy content
    Send("^{c}")
    Errorlevel := !ClipWait(1, 0)
    
    if (ErrorLevel != 0)
    {
        ; User has not made a text selection, start snipping tool
        Send("#+{s}")
        ErrorLevel := WinWaitActive("ahk_exe ScreenClippingHost.exe") , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Sleep(50)
        ErrorLevel := WinWaitNotActive("ahk_exe ScreenClippingHost.exe") , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Errorlevel := !ClipWait(1, 1)

        if (ErrorLevel != 0)
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
        
        if (highlightKey != "")
        {
            ; highlight text
            Send(highlightKey)
            Sleep(500)
        }
    }
    
    ; Window switch to SM
    WinActivate("ahk_pid " smPID)
    ErrorLevel := WinWaitActive("ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    WinActivate("ahk_class TElWind ahk_pid " smPID)
    ErrorLevel := WinWaitActive("ahk_class TElWind ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    
    if (target == 0)
    {
        ; create new extract
        createNewChildTopic(true, smPID)
    }
    else
    if (target == 1)
    {
        ; append to previous extract
        ; switch to previous element
        prevEl := WinGetTitle("A")
        Send("!{left}")
        waitElement(prevEl, smPID)
        
        ; move the cursor to the end of the topic
        moveCursorToEnd(smPID)
    }
    else
    if (target == 2)
    {
        prevEl := WinGetTitle("A")
        Send("!{left}")
        waitElement(prevEl, smPID)
        prevEl := WinGetTitle("A")
        Send("!{right}")
        waitElement(prevEl, smPID)
        moveCursorToEnd(smPID)
    }
    else
    {
        MsgBox("target argument has to be 0, 1 or 2", "Error!", 0)
        A_Clipboard := ClipSaved
        ClipSaved := ""
        Return
    }
    Sleep(100)
    
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
            Send("^+{m}")
            ErrorLevel := WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            Send("article picture")
            Send("{enter}")
            
            ErrorLevel := WinWaitNotActive("ahk_class TRegistryForm ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            ErrorLevel := WinWaitActive("ahk_class TElWind ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            
            ; paste image
            Send("^{v}")
            ErrorLevel := WinWaitActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            Send("{Enter}")
            ErrorLevel := WinWaitNotActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        }
        else
        if ( (target == 1) OR (target == 2) )
        {
            ; paste image
            Send("^{v}")
            ErrorLevel := WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            Send("{enter}")
            while ( (WinActive("ahk_class TChoicesDlg") == 0) AND (WinActive("ahk_class TMsgDialog") == 0) )
                Sleep(50)
            Send("{enter}")
            ErrorLevel := WinWaitActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
            Send("{enter}")
            ErrorLevel := WinWaitNotActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        }
    }
    else
    {
        MsgBox("Could not determine if you made a text or image extract.", "Error!", 0)
        A_Clipboard := ClipSaved
        ClipSaved := ""
        Return
    }
    
    if (target != 2)
    {
        ; go to parent
        prevEl := WinGetTitle("A")
        Send("^{up}")
        waitElement(prevEl, smPID)
    }
    
    ; switch back to application
    ; TODO: switch to winactivate
    Send("!{tab}")
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return
}

