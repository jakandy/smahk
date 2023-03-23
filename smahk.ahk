; Title:
;   SuperMemo AHK
;
; Version:
;   v1.0.0, 03/2023
;
; Author:
;   andyjak
;
; Description:
;   This script automates the UI of SuperMemo using AutoHotkey.
;   The script is a "master script", meant to be running concurrently
;   with SuperMemo. For more information, see the README.
;
; Usage:
;   See the README
;
; Tested with:
;   - SuperMemo, version 18.05
;   - AutoHotkey, version 2.0.2
;   - Mozilla Firefox, version 102.9.0esr (64-bit)
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
#Include <smahk-lib-Extract>         ; Module for the extract functionality
#Include <smahk-lib-ImageOcclusion>  ; Module for image occlusion functions
#Include <smahk-lib-MarkAndRecall>   ; Module for mark and recall functions

; ******************************************************************************
; ********************************** SETTINGS **********************************
; ******************************************************************************
; Run configurator if unable to load settings
if not FileExist("smahk-settings.ini")
    GoTo("Configuration")

knoPath := IniRead("smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("smahk-settings.ini", "Settings", "smProcessName")
browserProcessName := IniRead("smahk-settings.ini", "Settings", "browserProcessName")

if ( (knoPath == "") OR (smProcessName == "") OR (browserProcessName == "") )
    GoTo("Configuration")

; ******************************************************************************
; ************************************ INIT ************************************
; ******************************************************************************
; Start SM unless already running
if ( WinExist("ahk_exe " . smProcessName) == 0 )
    Run(knoPath, , , &smPID)
else
    smPID := WinGetPID("ahk_exe " smProcessName)

; Save the ID of the current SM process
WinWait("ahk_pid " smPID)
IniWrite(smPID, "smahk-settings.ini", "Settings", "smPID")
Sleep(3000)
GoTo("Main")

; ******************************************************************************
; ************************************ MAIN ************************************
; ******************************************************************************
Main:
    ; Wait for close event
    WinWaitClose("ahk_pid " smPID)
    ExitApp()

; ******************************************************************************
; ************************* GENERAL KEYBOARD SHORTCUTS *************************
; ******************************************************************************
!esc::
{
    KeyWait("alt")
    ExitApp()
}

+esc::
{
    KeyWait("shift")
    Reload()
}

^!x::
{
    KeyWait("ctrl")
    KeyWait("alt")
    anyExtract(0, smPID)
    return
}

^+x::
{
    KeyWait("ctrl")
    KeyWait("shift")
    anyExtract(1, smPID)
    return
}

!+x::
{
    KeyWait("alt")
    KeyWait("shift")
    anyExtract(2, smPID)
    return
}

; ******************************************************************************
; *********************** WEB BROWSER KEYBOARD SHORTCUTS ***********************
; ******************************************************************************
#HotIf ( WinActive("ahk_exe " . browserProcessName))

^!i::
{
    IniWrite(smPID, "smahk-settings.ini", "Settings", "smPID")
    Run("bin\smahk-WebImporter.ahk")
    return
}

#HotIf

; ******************************************************************************
; ************************ SUPERMEMO KEYBOARD SHORTCUTS ************************
; ******************************************************************************
#HotIf ( WinActive("ahk_pid " . smPID))

^!o::
{
    KeyWait("ctrl")
    KeyWait("alt")
    imageOcclusion(smPID)
    return
}

^!n::
{
    KeyWait("ctrl")
    KeyWait("alt")
    createNewChildTopic(false, smPID)
    return
}

^+<::
{
    KeyWait("ctrl")
    KeyWait("shift")
    Send("^+{1}")
    Return
}

^!h::
{
    KeyWait("ctrl")
    KeyWait("alt")
    clearSearchHighlights(smPID)
    Return
}

^!c::
{
    KeyWait("ctrl")
    KeyWait("alt")
    Run("bin\smahk-ConceptMenu.ahk")
    Return
}

^!MButton::
{
    KeyWait("ctrl")
    KeyWait("alt")
    activeControl := ControlGetClassNN(ControlGetFocus("ahk_class TElWind ahk_pid " smPID))
    if (InStr(activeControl, "Internet Explorer_Server"))
        openLinkAtMousePos(smPID)
    return
}

^!f12::
{
    KeyWait("ctrl")
    KeyWait("alt")
    Run("bin\smahk-Backup.ahk")
    return
}

^!Enter::
{
    KeyWait("ctrl")
    KeyWait("alt")
    markedEl := markElement(smPID)
    IniWrite(markedEl, "smahk-settings.ini", "Settings", "markedElement")
    return
}

^!Backspace::
{
    KeyWait("ctrl")
    KeyWait("alt")
    markedEl := IniRead("smahk-settings.ini", "Settings", "markedElement")

    if (markedEl == "")
        MsgBox("No element has been marked.", "Error!", 0)
    else
        recallElement(markedEl, smPID)
    
    Return
}

!0::
{
    randPrio := Random(0.0000, 1.0000)
    setPriority(randPrio, smPID)
    return
}

!1::
{
    randPrio := Random(1.0000, 10.0000)
    setPriority(randPrio, smPID)
    return
}

!2::
{
    randPrio := Random(10.0000, 20.0000)
    setPriority(randPrio, smPID)
    return
}

!3::
{
    randPrio := Random(20.0000, 30.0000)
    setPriority(randPrio, smPID)
    return
}

!4::
{
    randPrio := Random(30.0000, 40.0000)
    setPriority(randPrio, smPID)
    return
}

!5::
{
    randPrio := Random(40.0000, 50.0000)
    setPriority(randPrio, smPID)
    return
}

!6::
{
    randPrio := Random(50.0000, 60.0000)
    setPriority(randPrio, smPID)
    return
}

!7::
{
    randPrio := Random(60.0000, 70.0000)
    setPriority(randPrio, smPID)
    return
}

!8::
{
    randPrio := Random(70.0000, 80.0000)
    setPriority(randPrio, smPID)
    return
}

!9::
{
    randPrio := Random(80.0000, 99.9999)
    setPriority(randPrio, smPID)
    return
}

#HotIf

; ******************************************************************************
; ************************** CONFIGURATION SUBROUTINE **************************
; ******************************************************************************
Configuration:
    ; TODO: add option to change default keyboard bindings for smahk

    if not FileExist("smahk-settings.ini")
        FileAppend("", "smahk-settings.ini")

    knoPath := IniRead("smahk-settings.ini", "Settings", "knoPath", "ERROR")
    if (knoPath == "ERROR")
        knoPath := ""

    browserPath := IniRead("smahk-settings.ini", "Settings", "browserPath", "ERROR")
    if (browserPath == "ERROR")
        browserPath := ""

    ; show import options GUI
    myGui := Gui(, "SuperMemo AHK Configuration")
    myGui.OnEvent("Escape", ButtonCancel.Bind("Normal", myGui))
    myGui.Add("Text", "xm", "SuperMemo Collection path:")
    ogcEditUIknoPath := myGui.Add("Edit", "r1 vUIknoPath w135", knoPath)
    ogcButtonBrowse := myGui.Add("Button", "x+m", "Browse")
    ogcButtonBrowse.OnEvent("Click", BtnSM.Bind("Normal"))
    myGui.Add("Text", "xm", "Web browser path:")
    ogcEditUIBrowserPath := myGui.Add("Edit", "r1 vUIBrowserPath w135", browserPath)
    ogcButtonBrowse := myGui.Add("Button", "x+m", "Browse")
    ogcButtonBrowse.OnEvent("Click", BtnWeb.Bind("Normal"))
    ogcButtonOK := myGui.Add("Button", "default xm", "OK")
    ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
    ogcButtonCancel := myGui.Add("Button", "x+m", "Cancel")
    ogcButtonCancel.OnEvent("Click", ButtonCancel.Bind("Normal"))
    myGui.Show()

    BtnSM(A_GuiEvent, GuiCtrlObj, Info, *)
    {
        knoPath := FileSelect("", "", "Select the SuperMemo collection you want to use with smahk", "Knowledge collection (*.kno)")
        ogcEditUIknoPath.Value := knoPath
        return
    }
        
    BtnWeb(A_GuiEvent, GuiCtrlObj, Info, *)
    {
        browserPath := FileSelect("", "", "Select the executable of the web browser to use for SuperMemo imports", "Executable (*.exe)")
        ogcEditUIBrowserPath.Value := browserPath
        return
    }

    ButtonOK(A_GuiEvent, GuiCtrlObj, Info, *)
    {
        oSaved := myGui.Submit()
        IniWrite(oSaved.UIknoPath, "smahk-settings.ini", "Settings", "knoPath")
        IniWrite(oSaved.UIBrowserPath, "smahk-settings.ini", "Settings", "browserPath")
        
        if (oSaved.UIknoPath != "")
            smProcessName := "sm18.exe"
        else
            smProcessName := ""
        IniWrite(smProcessName, "smahk-settings.ini", "Settings", "smProcessName")
        
        if (oSaved.UIBrowserPath != "")
            browserProcessName := SubStr(oSaved.UIBrowserPath, InStr(oSaved.UIBrowserPath,"\",,-1)+1)
        else
            browserProcessName := ""
        IniWrite(browserProcessName, "smahk-settings.ini", "Settings", "browserProcessName")
        
        ExitApp()
    }

    ButtonCancel(A_GuiEvent, GuiCtrlObj, Info, *)
    {
        ExitApp()
    }