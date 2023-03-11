﻿; Title:
;   SuperMemo AHK
;
; Version:
;   0.1, 09/2022
;
; Author:
;   andyjak
;
; Description:
;   This script automates the UI using simulated keyboard and mouse presses
;   to improve the user experience of SuperMemo. The scripting language used
;   is AutoHotkey.
;   The script is meant to be running concurrently with SuperMemo to call
;   different functions using hotkeys.
;
; Installation instructions:
;   Exe: Extract smahk.exe in any directory and run it.
;   Ahk: Extract all files with the prefix "smahk-" in any directory and
;        run smahk.ahk (requires AutoHotkey to be installed).
;   Be aware that only one collection can be used for each smahk installation.
;   To use smahk with several collection you will therefore need to copy
;   and paste the files in separate directories.
;   The first time running the script you will be prompted to specify the file
;   path for: SuperMemo and the web browser you want to use for web imports.
;   The paths can also be changed manually by editing smahk-settings.ini
;   or by running smahk-Config.ahk if you are using the ahk-version.
;
; Usage:
;   When the script and SuperMemo is running, press any of the below hotkeys to
;   perform the associated action.
;
;       General hotkeys (can be invoked anywhere):
;       - Ctrl-Alt-X: Extract text or image into new topic
;       - Ctrl-Shift-X: Extract text or image into previous topic
;       - Alt-Shift-X: Extract text or image into current topic
;       - Alt-Esc: Terminate script
;       - Shift-Esc: Reload script
;
;       Browser hotkeys:
;       - Ctrl-Alt-I: Import web article (GUI)
;
;       SuperMemo hotkeys:
;       - Alt-1-9: Change priority of current element to certain range
;       - Ctrl-Alt-Middleclick: Open a hyperlink in web browser
;       - Ctrl-Alt-O: Create image occlusion item
;       - Ctrl-Alt-N: Create new child topic
;       - Ctrl-Alt-C: Show GUI for concept options
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
#Include <smahk-Extract>         ; Module for the extract functionality
#Include <smahk-ImageOcclusion>  ; Module for image occlusion functions

; ******************************************************************************
; ********************************** SETTINGS **********************************
; ******************************************************************************
if not FileExist("smahk-settings.ini")
{
    Run("smahk-Configurator.ahk")
    ExitApp()
}

; Load settings
knoPath := IniRead("smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("smahk-settings.ini", "Settings", "smProcessName")
browserProcessName := IniRead("smahk-settings.ini", "Settings", "browserProcessName")

; Run configurator if unable to find settings
if ( (knoPath == "ERROR") OR ((knoPath == "")) OR (smProcessName == "ERROR") OR ((smProcessName == "")) )
{
    Run("smahk-Config.ahk")
    ExitApp()
}

; ******************************************************************************
; ************************************ MAIN ************************************
; ******************************************************************************
; Start SM unless already running
if ( WinExist("ahk_exe " . smProcessName) == 0 )
    Run(knoPath, , , &smPID)
else
    smPID := WinGetPID("ahk_exe " smProcessName)

WinWait("ahk_pid " smPID)
Sleep(3000)

; Terminate SM on window close
writeToINI(smPID)
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
    anyExtract(0, "", smPID)
    return
}

^+x::
{
    KeyWait("ctrl")
    KeyWait("shift")
    anyExtract(1, "", smPID)
    return
}

!+x::
{
    KeyWait("alt")
    KeyWait("shift")
    anyExtract(2, "", smPID)
    return
}

; ******************************************************************************
; *********************** WEB BROWSER KEYBOARD SHORTCUTS ***********************
; ******************************************************************************
#HotIf ( WinActive("ahk_exe " . browserProcessName))

^!i::
{
    writeToINI(smPID)
    Run("lib\smahk-WebImporter.ahk")
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
    Run("lib\smahk-ConceptMenu.ahk")
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
    Run("lib\smahk-Backup.ahk")
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

!0::
{
    randPrio := Random(0.0000, 1.0000)
    setPriority(randPrio, smPID)
    return
}
#HotIf


; ******************************************************************************
; ********************************* FUNCTIONS **********************************
; ******************************************************************************
; Function name: writeToINI
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
writeToINI(smPID)
{
    ; Process ID of SuperMemo
    IniWrite(smPID, "smahk-settings.ini", "Settings", "smPID")
    return
}
