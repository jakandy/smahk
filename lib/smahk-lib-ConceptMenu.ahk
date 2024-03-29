﻿; Title:
;   SuperMemo AHK - Concept menu module
;
; Version:
;   1.0.1, 08/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   easier perform various concept-related actions.
;
; Usage:
;   This script is meant to be executed from the main script (smahk.ahk)
;   using the Run()-function. When run this script will display a GUI with
;   the options shown below:
;   - Create concept: Convert the current element to a concept
;   - Link to concept: Add a link between the current element and a concept using the registry
;   - Link to multiple concepts: Same as above but several times until the user presses "Esc".
;   - Unlink concept: Remove a link between the current element and a concept using the registry
;   - Link to element in contents window: Add a link between the current element
;                                         and an element in the contents window
;   - List links: Display the links of the current element in the browser
;   - Set default concept group: Lets the user choose a concept to set as default concept.
;   - Move to concept: Lets the user choose a concept to move the current element to.
;   - Search for concept: Activates the search bar in the element window.
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
InstallKeybdHook()                   ; Used for enabling A_PriorKey variable
KeyHistory(2)                        ; Number of previous keypresses in history

; ******************************************************************************
; ************************************* FUNCTIONS ******************************
; ******************************************************************************
; Function name: createConcept
; --------------------
;
; Description:
;   Lets the user create a concept from the current element.
;   Equivalent to "alt-f10 -> Concepts -> Create concept"
;   which has wParam value 643.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
createConcept(smPID)
{
    sendContextMenuCommand(643, smPID)
    return
}

; Function name: linkToConcept
; --------------------
;
; Description:
;   Lets the user add a link between the current element and a concept.
;   Equivalent to "alt-f10 -> Concepts -> Link concept"
;   which has wParam value 644.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
linkToConcept(smPID)
{
    listLinks(smPID)
    WinWaitActive("ahk_class TBrowser ahk_pid " smPID)
    sendContextMenuCommand(644, smPID)
    WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID)
    WinWaitClose("ahk_class TRegistryForm ahk_pid " smPID)
    listLinks(smPID)
    return
}

; Function name: linkToMultConcepts
; --------------------
;
; Description:
;   Calls the linkToConcept() function several times until the user presses esc.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
linkToMultConcepts(smPID)
{
    ; TODO: fix bug when clicking on close window
    while ( (A_Index == 1) OR (A_PriorKey != "Escape") )
    {
        listLinks(smPID)
        WinWaitActive("ahk_class TBrowser ahk_pid " smPID)
        sendContextMenuCommand(644, smPID)
        WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID)
        
        while !WinWaitClose("ahk_class TRegistryForm ahk_pid " smPID,, 0.5)
        {
            if WinActive("ahk_class TMyFindDlg")
                return
        }
        KeyWait("Escape")
        Sleep(100)
    }
    listLinks(smPID)
    return
}

; Function name: unlinkFromConcept
; --------------------
;
; Description:
;   Lets the user remove a link between the current element and a concept.
;   Equivalent to "alt-f10 -> Concepts -> Unlink concept"
;   which has wParam value 645.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
unlinkFromConcept(smPID)
{
    listLinks(smPID)
    WinWaitActive("ahk_class TBrowser ahk_pid " smPID)
    sendContextMenuCommand(645, smPID)
    WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID)
    WinWaitClose("ahk_class TRegistryForm ahk_pid " smPID)
    listLinks(smPID)
    return
}

; Function name: linkContents
; --------------------
;
; Description:
;   Lets the user link two elements using the contents window.
;   Equivalent to "alt-f10 -> Concepts -> Link contents"
;   which has wParam value 649.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
linkContents(smPID)
{
    sendContextMenuCommand(649, smPID)
    return
}

; Function name: listLinks
; --------------------
;
; Description:
;   Lists the links for the current element in the browser.
;   Equivalent to "alt-f10 -> Concepts -> List links"
;   which has wParam value 652.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
listLinks(smPID)
{
    sendContextMenuCommand(652, smPID)
    return
}

; Function name: moveToConcept
; --------------------
;
; Description:
;   Brings up the element parameter window and activates the concept dropdown.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
moveToConcept(smPID)
{
    safeActivateElementWindow(smPID)
    
    Send("^+{p}")
    WinWaitActive("ahk_class ahk_class TElParamDlg ahk_pid " smPID)
    Send("!{g}")
    return
}

; Function name: searchConcept
; --------------------
;
; Description:
;   Activates the search bar for concepts in the top toolbar in the
;   element window by sending a mouse click to the middle of the search bar.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
searchConcept(smPID)
{
    safeActivateElementWindow(smPID)
    ControlGetPos(&conceptSearchBarX, , , , "TEdit1", "ahk_class TElWind ahk_pid " smPID)
    if (conceptSearchBarX == 0)
    {
        ; could not find the concept search bar
        MsgBox("Could not find the concept search bar.", "Error!", 0)
    }
    else
    {
        SetControlDelay(-1)
        ControlClick("TEdit1")
    }
    return
}

; Function name: setDefaultConcept
; --------------------
;
; Description:
;   Lets the user set the default concept group. Equivalent to clicking
;   the lightbulb button next to the concept search bar in the top toolbar
;   in the element window.
;
; Input parameter:
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
setDefaultConcept(smPID)
{
    safeActivateElementWindow(smPID)
    ControlGetPos(&conceptSearchBarX, &conceptSearchBarY, , &conceptSearchBarH, "TEdit1", "ahk_class TElWind ahk_pid " smPID)
    if (conceptSearchBarX == 0)
    {
        ; could not find the concept search bar
        MsgBox("Could not find the concept search bar.", "Error!", 0)
    }
    else
    {
        clickPosX := conceptSearchBarX - 10    ; a toolbar button is ~20 px wide
        clickPosY := conceptSearchBarY + (conceptSearchBarH/2)
        SetControlDelay(-1)
        ControlClick("x" clickPosX " y" clickPosY)
    }
    return
}
