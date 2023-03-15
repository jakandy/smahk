; Title:
;   SuperMemo AHK - AutoHotkey library
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   This file contains various functions written in AutoHotkey script language
;   to be used for automating the UI in SuperMemo.
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

; Function name: setPriority
; --------------------
;
; Description:
;   Sets the priority of the current element.
;
; Input parameter:
;   prio - Priority value of the element (0-100)
;
; Return:
;   0 - if priority was successfully set
;   -1 - if priority window was not able to be opened
;
setPriority(prio, smPID)
{
    Send("!{p}")
    ErrorLevel := WinWaitActive("ahk_class TPriorityDlg ahk_pid " smPID, , 3) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    if (ErrorLevel != 0)
        return -1
    Send(prio)
    Send("{Enter}")
    ErrorLevel := WinWaitNotActive("ahk_class TPriorityDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
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
;   smPID - integer containing the process ID of SuperMemo
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
;   -1 - if loop times out before text cursor has been moved
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
;   ---
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
        waitTextCursor(start_CaretX, start_CaretY, timeout)
    }
    Return
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
;   smPID - integer containing the process ID of SuperMemo
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
;   ---
;
; Input parameter:
;   inheritance - bool deciding if properties should be inherited from parent
;   smPID - integer containing the process ID of SuperMemo
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
        ; TODO: change below to errorlevel
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
        ErrorLevel := WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("{enter}")
        ErrorLevel := WinWaitNotActive("ahk_class TMsgDialog ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("!{SC029}")                  ; SC029 = § character
        ErrorLevel := WinWaitActive("ahk_class TMsgDialog ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("{enter}")
        ErrorLevel := WinWaitNotActive("ahk_class TMsgDialog ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    else
    {
        Send("!{c}")
        ErrorLevel := WinWaitActive("ahk_class TContents ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        
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
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
setRef(refsString, choicesDlg, smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    
    ; Open edit references window
    sendContextMenuCommand(660, smPID)
    ErrorLevel := WinWaitActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    WinActivate("ahk_class TInputDlg ahk_pid " smPID)
    ErrorLevel := WinWaitActive("ahk_class TInputDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    
    ; Enter references
    A_Clipboard := ""
    A_Clipboard := refsString
    Errorlevel := !ClipWait(1, 0)
    safePasteText()
    Send("^{Enter}")
    
    if (choicesDlg == true)
    {
        ErrorLevel := WinWaitActive("ahk_class TChoicesDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("{enter}")
        ErrorLevel := WinWaitNotActive("ahk_class TChoicesDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
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
;   smPID - integer containing the process ID of SuperMemo
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
    Errorlevel := !ClipWait(1, 0)
    
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
            Errorlevel := !ClipWait(1, 0)
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
;   ---
;
; Input parameter:
;   smPID - integer containing the process ID of SuperMemo
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
    ErrorLevel := WinWaitActive("ahk_class TCommanderDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    Send("highlight: clear")
    Send("{enter}")
    ErrorLevel := WinWaitNotActive("ahk_class TCommanderDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    return
}


; Function name: listFiles
; --------------------
;
; Description:
;   ---
;
; Input parameter:
;   ---
;
; Return:
;   ---
;
listFiles(dir)
{
	files := ""
	Loop Files, dir "\*.*"
	{
		files := files . "`n" . A_LoopFileName
	}
	return files
}



; Function name: safeActivateElementWindow
; --------------------
;
; Description:
;   Activates the element window in SM unless it is already active.
;
; Input parameter:
;   smPID - integer containing the process ID of SuperMemo
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
;
; Input parameter:
;   wParam - integer containing the command to send
;   smPID - integer containing the process ID of SuperMemo
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