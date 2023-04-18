; Title:
;   SuperMemo AHK - AutoHotkey library
;
; Version:
;   v1.0.1, 04/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It is a library containing functions to
;   perform tasks that can be used for any script.
;
; Usage:
;   Place this file in any directory and include it to your script using
;   the #include directive. After that you can call any function as normal.
;   Please read the header of each function for more info about
;   what they do and how to use them.
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

; ******************************************************************************
; ************************************* FUNCTIONS ******************************
; ******************************************************************************
; Function name: setPriority
; --------------------
;
; Description:
;   Sets the priority of the current element.
;
; Input parameter:
;   prio - Priority value of the element (0-100)
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   0 - if priority was successfully set
;   -1 - if priority window was not able to be opened
;
setPriority(prio, smPID)
{
    Send("!{p}")
    if (!WinWaitActive("ahk_class TPriorityDlg ahk_pid " smPID,, 3))
        return -1
    Send(prio)
    Send("{Enter}")
    WinWaitNotActive("ahk_class TPriorityDlg ahk_pid " smPID)
    return 0
}


; Function name: waitElement
; --------------------
;
; Description:
;   Loop to wait until SM has switched to a new element.
;   Save the title of the previous element with WinGetTitle in a variable
;   "previousEl" and then call this function: waitElement(previousEl, smPID).
;   If it doesn't work, try putting a time delay before the function call.
;
; Input parameter:
;   previousEl - String of the window title of the previous element.
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
waitElement(previousEl, smPID)
{
    while ( (A_Index == 1) OR (previousEl == nextEl) )
    {
        nextEl := WinGetTitle("ahk_class TElWind ahk_pid " smPID)
        Sleep(50)
    }
    Sleep(100)
    Return
}

; Function name: waitTextCursor
; --------------------
;
; Description:
;   Loop for waiting for text to be pasted before continuing.
;   Save the text cursor (caret) position before pasting, then call this
;   function after pasting.
;
; Input parameter:
;   start_CaretX - horizontal position of text cursor before paste operation
;   start_CaretY - vertical position of text cursor before paste operation
;   timeout - number of milliseconds elapse until loop should break
;
; Return:
;   0 - if text cursor has been moved
;   1 - if loop times out before text cursor has been moved
;
waitTextCursor(start_CaretX, start_CaretY, timeout := 10000)
{
    startTime := A_TickCount
    CaretGetPos(&current_CaretX, &current_CaretY) 
    while( (start_CaretX == current_CaretX) AND (start_CaretY == current_CaretY) )
    {
        if ( (A_TickCount - startTime) > timeout)
            Return -1
        CaretGetPos(&current_CaretX, &current_CaretY) 
        Sleep(50)
    }
    
    Return 0
    
}

; Function name: safePasteText
; --------------------
;
; Description:
;   Pastes the text from the clipboard and waits until the operation is done.
;
; Input parameter:
;   timeout - number of milliseconds elapse until loop should break
;
; Return:
;   timedout - 1 if function timeout has been reached, 0 otherwise
;
safePasteText(timeout := 10000)
{
    if (A_Clipboard != "")
    {
        CaretFound := CaretGetPos(&start_CaretX, &start_CaretY)
        while (CaretFound == 0)
        {
            CaretFound := CaretGetPos(&start_CaretX, &start_CaretY)
            Sleep(50)
        }
        Send("^{v}")
        timedout := waitTextCursor(start_CaretX, start_CaretY, timeout)
    }
    Return timedout
}

; Function name: openLinkAtMousePos
; --------------------
;
; Description:
;   Opens the link at the mouse cursors position in an element in SM.
;   Equivalent to right-clicking a link and selecting "Open in new window".
;   If there is no link where the user clicks, it will open the element
;   in the browser.
;   The html component should be active for this to work.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
openLinkAtMousePos(smPID)
{
    MouseClick()
    sendContextMenuCommand(939, smPID)
    return
}

; Function name: createNewChildTopic
; --------------------
;
; Description:
;   Creates a new topic as a child to the current element.
;
; Input parameter:
;   inheritance - bool deciding if properties should be inherited from parent
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
createNewChildTopic(inheritance, smPID)
{
    ; Duplicate current element
    currentEl := WinGetTitle("A")
    if ( (InStr(currentEl, "Concept:")) AND (inheritance == true) )
    {
        msgResult := MsgBox("Create extract from concept?", "Warning!", 4)
        if (msgResult = "No")
            return -1
    }

    if (inheritance == true)
    {
        Send("!{d}")
        waitElement(currentEl, smPID)
        
        ; Make sure extract is a topic
        sendContextMenuCommand(738, smPID)
        
        ; Clear contents of the html component
        Send("{q}")
        Send("!{.}")
        WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID)
        Send("{enter}")
        WinWaitNotActive("ahk_class TMsgDialog ahk_pid " smPID)
        Send("!{SC029}")                  ; SC029 = § character
        WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID)
        Send("{enter}")
        WinWaitNotActive("ahk_class TMsgDialog ahk_pid " smPID)
    }
    else
    {
        Send("!{c}")
        WinWaitActive("ahk_class TContents ahk_pid " smPID)
        
        sendContextMenuCommand(465, smPID)
        WinClose("ahk_class TContents ahk_pid " smPID)
        Send("{q}")
    }
    
    return
}


; Function name: setRef
; --------------------
;
; Description:
;   Set references for the current element. The refs string needs to be
;   formatted according to:
;       #Title: ...
;       #Date: ...
;       #Link: ...
;       etc.
;
; Input parameter:
;   refs - formatted string of references
;   choicesDlg - true: close TChoicesDlg if it shows up
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
setRef(refsString, choicesDlg, smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    
    ; Open edit references window
    safeActivateElementWindow(smPID)
    Sleep(50)
    sendContextMenuCommand(660, smPID)
    WinWaitActive("ahk_class TInputDlg ahk_pid " smPID)
    
    ; Enter references
    A_Clipboard := ""
    A_Clipboard := refsString
    if ( !ClipWait(1, 0) )
    {
        MsgBox("Clipboard failure.", "Error!", 0)
        return
    }
    
    if (safePasteText(1000) == -1)
    {
        MsgBox("Unable to set references.", "Error!", 0)
        WinWaitActive("ahk_class TInputDlg ahk_pid " smPID)
        Send("{Esc}")
        WinWaitNotActive("ahk_class TInputDlg ahk_pid " smPID)
        return
    }
    Send("^{Enter}")
    
    if (choicesDlg == true)
    {
        WinWaitActive("ahk_class TChoicesDlg ahk_pid " smPID)
        Send("{enter}")
        WinWaitNotActive("ahk_class TChoicesDlg ahk_pid " smPID)
    }
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return
}


; Function name: safeCopyToClipboard
; --------------------
;
; Description:
;   Copies the input to the clipboard and returns only when all data
;   has been transferred.
;   Can be used as an alternative to ClipWait if it fails to do the job.
;
; Input parameter:
;   data - variable containing data to be copied to the clipboard
;   timeout - number of milliseconds elapse until loop should break
;
; Return:
;   ---
;
safeCopyToClipboard(data, timeout := 1000)
{
    startTime := A_TickCount
    A_Clipboard := data
    while (A_Clipboard != data)
    {
        if ( (A_TickCount - startTime) > timeout)
            Return -1
        
        Sleep(50)
    }
    
    Return 0
}

; Function name: moveCursorToEnd
; --------------------
;
; Description:
;   Moves the text cursor to the end of an HTML component.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
moveCursorToEnd(smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    
    safeActivateElementWindow(smPID)
    ; check if element has a reference
    Send("{q}")
    Send("^{end}")
    Send("{home}")
    
    Send("+{right}")
    Send("^{c}")
    if ( !ClipWait(1, 0) )
    {
        MsgBox("Clipboard failure.", "Error!", 0)
        return
    }
    
    if (A_Clipboard == "#")
    {
        ; element has references
        while (A_Clipboard != "#SuperMemo Reference:")
        {
            A_Clipboard := ""
            Send("{left}")
            Send("{up}")
            Send("+{end}")
            Send("^{c}")
            if ( !ClipWait(1, 0) )
            {
                MsgBox("Clipboard failure.", "Error!", 0)
                return
            }
        }
        Send("{left}")
        Send("{up}")
        Send("{up}")
    }
    else
    {
        ; element does not have references
        Send("^{end}")
        Send("{enter}")
    }
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return
}


; Function name: clearSearchHighlights
; --------------------
;
; Description:
;   Removes the highlights that appear after a search has been made.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
clearSearchHighlights(smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    
    safeActivateElementWindow(smPID)
    
    Send("^{enter}")
    WinWaitActive("ahk_class TCommanderDlg ahk_pid " smPID)
    Send("highlight: clear")
    Send("{enter}")
    WinWaitNotActive("ahk_class TCommanderDlg ahk_pid " smPID)
    return
}

; Function name: safeActivateElementWindow
; --------------------
;
; Description:
;   Activates the element window in SM unless it is already active.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
safeActivateElementWindow(smPID)
{
    if (WinActive("ahk_class TElWind") == 0)
    {
        WinActivate("ahk_pid " . smPID)
        WinWaitActive("ahk_pid " . smPID)
        WinActivate("ahk_class TElWind ahk_pid " . smPID)
        WinWaitActive("ahk_class TElWind ahk_pid " . smPID)
    }
    return
}

; Function name: sendContextMenuCommand
; --------------------
;
; Description:
;   Directly activates a command from a context menu without having to
;   navigate through menu options.
;   It sends a WM_COMMAND message using the PostMessage function.
;   The wParam value represents the command to send and can be found by
;   using an application window tool like Spy++ or Window Detective.
;   The wParam argument values changes between SuperMemo versions. 
;   To update the functions for other versions, new wParam values need to
;   be found using a software like Spy++.
;
; Input parameter:
;   wParam - the command to send
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
sendContextMenuCommand(wParam, smPID)
{
    DetectHiddenWindows(true)
    ocontextMenuID := WinGetList("ahk_class TPUtilWindow ahk_pid " smPID,,,)
    acontextMenuID := Array()
    contextMenuID := ocontextMenuID.Length
    
    for v in ocontextMenuID
    {
        acontextMenuID.Push(v)
    }
    
    PostMessage(0x0111, wParam, , , "ahk_id " acontextMenuID[5]) ; 5th element = id of context menu
    DetectHiddenWindows(false)
    return
}

; Function name: detectImageComponent
; --------------------
;
; Description:
;   Detects if there is an image component in the current element.
;   If there is an image component, focus is shifted to that control
;   by opening and closing the "Process images" dialog.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   0 - if no image component is found the current element
;   1 - if an image component is found the current element
;
detectImageComponent(smPID)
{
    safeActivateElementWindow(smPID)
    Send("^+{f8}")
    while (WinActive("ahk_class TChoicesDlg ahk_pid " . smPID) == 0)
    {
        if (WinActive("ahk_class TMsgDialog ahk_pid " . smPID))
            return 0
        
        Sleep(50)
    }
    Send("{Escape}")
    WinWaitNotActive("ahk_class TChoicesDlg ahk_pid " . smPID)
    return 1
}
