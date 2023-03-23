; Title:
;   SuperMemo AHK - Auto Repair module
;
; Version:
;   v1.0.0, 03/2023
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
;   This script is meant to be executed from the main script (smahk.ahk)
;   using the Run()-function. When run this script will automatically
;   run the in-built repair utility in SuperMemo.
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

detailedRepair := true              ; set to false if to run basic repair

knoPath := IniRead("..\smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if ( (knoPath == "") OR (smProcessName == "") )
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

if (ProcessExist(smProcessName))
{
    WinClose("ahk_exe " smProcessName)
    WinWaitClose("ahk_exe " smProcessName)
}

Run(knoPath)
WinWait("ahk_exe " smProcessName)
if ( !WinWaitActive("ahk_class TElWind",, 5) )
    ExitApp()
Send("^{f12}")
WinWaitActive("ahk_class TRecoveryDialog")
Sleep(10000)
if (detailedRepair == true)
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
WinWaitActive("ahk_exe notepad++.exe")
Sleep(3000)
Send("!{tab}")
Sleep(5000)

; Close SM if no errors during repair
if ( WinActive("ahk_class TMsgDialog", "Error!") == 0 )
{
    WinActivate("ahk_exe " smProcessName)
    WinWaitActive("ahk_exe " smProcessName)
    WinActivate("ahk_class TElWind")
    if ( !WinWaitActive("ahk_class TElWind", , 5) )
    {
        MsgBox("Could not activate element window.", "Error!", 0)
        ExitApp()
    }
    Sleep(3000)
    Send("!{f4}")
    WinWaitClose("ahk_exe " smProcessName)
    Sleep(1000)
}

ExitApp()
