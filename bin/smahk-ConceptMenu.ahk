; Title:
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
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#SingleInstance ignore
SetKeyDelay(0, 10)
#Include "..\lib\smahk-lib-ConceptMenu.ahk"
InstallKeybdHook()                   ; Used for enabling A_PriorKey variable
KeyHistory(2)                        ; Number of previous keypresses in history

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
