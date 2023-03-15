; Title:
;   SuperMemo AHK - Auto Repair module
;
; Version:
;   v1.00, 03/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   automatically run the repair utility of SuperMemo.
;   It is meant to be run at a scheduled time, using Windows Task Scheduler.
;
; Usage:
;   Place this file in the same directory as the other files for smahk.
;   Add at the top of your script: "#Include smahk-WebImporter.ahk" without
;   quotes. When run this script will display a GUI where a user can choose
;   options to import articles.
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
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#SingleInstance ignore
SetKeyDelay(0, 10)

; ******************************************************************************
; ********************************* MAIN PROGRAM START *************************
; ******************************************************************************
knoPath := IniRead("..\smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if ( (knoPath == "") OR (smProcessName == "") )
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

ErrorLevel := ProcessExist(smProcessName)
if (ErrorLevel != 0)
{
    WinClose("ahk_exe " smProcessName)
    ErrorLevel := WinWaitClose("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
}

Run(knoPath)
ErrorLevel := WinWait("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
ErrorLevel := WinWaitActive("ahk_class TElWind", , 5) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
if (ErrorLevel != 0)
    ExitApp()
autoRepairCollection(true)
ErrorLevel := WinWaitActive("ahk_exe notepad++.exe") , ErrorLevel := ErrorLevel = 0 ? 1 : 0
Sleep(3000)
Send("!{tab}")
Sleep(5000)

; Close SM if no errors during repair
if ( WinActive("ahk_class TMsgDialog", "Error!") == 0 )
{
    WinActivate("ahk_exe " smProcessName)
    ErrorLevel := WinWaitActive("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    WinActivate("ahk_class TElWind")
    ErrorLevel := WinWaitActive("ahk_class TElWind", , 5) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    if (ErrorLevel != 0)
    {
        MsgBox("Could not activate element window.", "Error!", 0)
        ExitApp()
    }
    Sleep(3000)
    Send("!{f4}")
    ErrorLevel := WinWaitClose("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    Sleep(1000)
}

ExitApp()

; ******************************************************************************
; ********************************** MAIN PROGRAM END **************************
; ******************************************************************************

; Function name: autoRepairCollection
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
autoRepairCollection(detailed)
{
    Send("^{f12}")
    ErrorLevel := WinWaitActive("ahk_class TRecoveryDialog") , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    Sleep(10000)
    if (detailed == true)
    {
        Send("{down}")
        Sleep(1000)
        Send("{down}")
        Sleep(1000)
        Send("{Enter}")
        Sleep(1000)
        Send("{up}")
        Sleep(1000)
        Send("{up}")
    }
    Sleep(1000)
    Send("{enter}")
    
    return
}