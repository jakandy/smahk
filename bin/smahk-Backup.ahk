; Title:
;   SuperMemo AHK - Backup module
;
; Version:
;   v1.0.0, 03/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   backup the collection to a directory called "backup", located in the same
;   directory as sm18.exe.
;
; Usage:
;   This script is meant to be executed from the main script (smahk.ahk)
;   using the Run()-function. A messagebox will appear prompting the user
;   to start the backup process.
;   It essentially just copies the entire collection and pastes it to another
;   directory, nothing fancy. When the collection has successfully been backed up,
;   a confirmation messagebox will appear.
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

knoPathKno := IniRead("..\smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if ( (knoPathKno == "") OR (smProcessName == "") )
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

SourceFolder := SubStr(knoPathKno, 1, -4)
TargetFolder := SubStr(knoPathKno, 1, InStr(knoPathKno, "\systems\", , -2)) . "backup"

msgResult := MsgBox("The collection in:`n" SourceFolder "`n`nwill be backed up into:`n" TargetFolder "`n`n(Be aware that the process is performed silently without a progress bar. SuperMemo will also be closed during the process) `n `nContinue?", "SuperMemo AHK Backup", 4)
if (msgResult = "No")
    ExitApp()
    
if (ProcessExist(smProcessName))
{
    WinClose("ahk_exe " smProcessName)
    WinWaitClose("ahk_exe " smProcessName)
    Sleep(1000)
}

SplitPath(SourceFolder, &SourceFolderName)

currentTime := FormatTime("A_Now", "yyyy-MM-dd HH-mm")

; TODO: add a progress bar
Try
{
   DirCopy(SourceFolder, TargetFolder "\" currentTime "\" SourceFolderName)
   ErrorLevel := 0
}
Catch
{
   ErrorLevel := 1
}
Try
{
   FileCopy(knoPathKno, TargetFolder "\" currentTime)
   ErrorLevel := 0
}
Catch as Err
{
   ErrorLevel := Err.Extra
}

if (ErrorLevel != 0)
{
    MsgBox("Error! The folder could not be copied.", "SuperMemo AHK Backup", 0)
}
else
{
    msgResult := MsgBox("Backup done! `n `nWould you like to restart SuperMemo?", "SuperMemo AHK Backup", 4)
    if (msgResult = "Yes")
        Run("..\smahk.ahk")
}

ExitApp()
