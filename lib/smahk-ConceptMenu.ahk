; Title:
;   SuperMemo AHK - Concept menu module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   This file contains a GUI used for working with concepts in SuperMemo.
;   Many functions here uses the PostMessage function and some
;   wParam argument values changes between SuperMemo versions. 
;   This means that most functions will only work for the
;   version of SuperMemo listed in the requirements section below.
;   To update the functions for other versions, new wParam values need to
;   be found using a window application software like Spy++.
;
; Usage:
;   Place this file in the same folder as "smahk.ahk".
;   When run this script will display a GUI where a user can choose
;   options.
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
#Include "smahk-lib.ahk"             ; Custom subroutines used in the script.
InstallKeybdHook()                   ; Used for enabling A_PriorKey variable
KeyHistory(2)                       ; Number of previous keypresses in history

; ******************************************************************************
; ********************************* MAIN PROGRAM START *************************
; ******************************************************************************

smPID := IniRead("..\smahk-settings.ini", "Settings", "smPID")

; Show concept menu GUI
myGui := Gui(, "SuperMemo AHK Concept Menu")
myGui.OnEvent("Escape", ButtonCancel.Bind("Normal", myGui))
myGui.Add("Text", , "Concept options:")
myGui.Add("Radio", "checked vUIConceptCreate", "&Create concept")
myGui.Add("Radio", "vUIConceptLink", "&Link to concept")
myGui.Add("Radio", "vUIConceptLinkMult", "Link to mul&tiple concepts")
myGui.Add("Radio", "vUIConceptUnlink", "&Unlink from concept")
myGui.Add("Radio", "vUIConceptLinkContents", "L&ink to element in contents window")
myGui.Add("Radio", "vUIConceptListLinks", "Li&st links")
myGui.Add("Radio", "vUIConceptSet", "Set &default concept group")
myGui.Add("Radio", "vUIConceptMove", "&Move to concept")
myGui.Add("Radio", "vUIConceptSearch", "Searc&h for concept")
ogcButtonOK := myGui.Add("Button", "default xm", "&OK")
ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
ogcButtonCancel := myGui.Add("Button", "x+m", "C&ancel")
ogcButtonCancel.OnEvent("Click", ButtonCancel.Bind("Normal"))
myGui.Show()

; User has pressed OK
ButtonOK(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit()
    
    if (oSaved.UIConceptCreate == 1)
    {
        createConcept(smPID)
    }
    else
    if (oSaved.UIConceptLink == 1)
    {
        linkToConcept(smPID)
    }
    else
    if (oSaved.UIConceptLinkMult == 1)
    {
        linkToMultConcepts(smPID)
    }
    else
    if (oSaved.UIConceptUnlink == 1)
    {
        unlinkFromConcept(smPID)
    }
    else
    if (oSaved.UIConceptLinkContents == 1)
    {
        linkContents(smPID)
    }
    else
    if (oSaved.UIConceptListLinks == 1)
    {
        listLinks(smPID)
    }
    else
    if (oSaved.UIConceptMove == 1)
    {
        moveToConcept(smPID)
    }
    else
    if (oSaved.UIConceptSearch == 1)
    {
        searchConcept(smPID)
    }
    else
    if (oSaved.UIConceptSet == 1)
    {
        setDefaultConcept(smPID)
    }
    else
    {
        MsgBox("No choice selected.", "Error!", 0)
        ExitApp()
    }

    ExitApp()
}

; User has pressed cancel or esc
ButtonCancel(A_GuiEvent, GuiCtrlObj, Info, *)
{
    ExitApp()
}

; ******************************************************************************
; ********************************** MAIN PROGRAM END **************************
; ******************************************************************************

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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
;   ---
;
; Input parameter:
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
linkToMultConcepts(smPID)
{
    ; TODO: fix bug when clicking on close window or searching
    while ( (A_Index == 1) OR (A_PriorKey != "Escape") )
    {
        listLinks(smPID)
        WinWaitActive("ahk_class TBrowser ahk_pid " smPID)
        sendContextMenuCommand(644, smPID)
        WinWaitActive("ahk_class TRegistryForm ahk_pid " smPID)
        WinWaitClose("ahk_class TRegistryForm ahk_pid " smPID)
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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
;   smPID - integer containing the process ID of SuperMemo
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
