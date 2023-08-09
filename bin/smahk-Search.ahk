; Title:
;   SuperMemo AHK - Search module
;
; Version:
;   1.0.1, 08/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   search for an element in the collection from outside SuperMemo.
;   It is meant to be run using an application launcher, e.g. Keypirinha.
;
; Usage:
;   This script takes in a string as a command line argument, for example:
;   smahk-Search.ahk "search string"
;   or
;   smahk-Search.ahk search string
;   An application launcher can then be set up to launch this script
;   with a custom search command. Read the docs of your application launcher
;   on how to do this.
;   
; Test setup:
;   - SuperMemo, version 18.05
;   - AutoHotkey, version 2.0.2
;   - Keypirinha, version 2.26
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
#Include "..\lib\smahk-lib-Search.ahk"

searchstring := parseCmdArg()

if (searchstring == "")
{
    MsgBox("Empty search string.", "Error!", 0)
    ExitApp()
}

; Supermemo settings
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if (smProcessName == "ERROR")
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

; Start SM unless already running
if ( WinExist("ahk_exe " . smProcessName) == 0 )
{
    Run("..\smahk.ahk")
    WinWaitActive("ahk_exe " . smProcessName)
    smPID := WinGetPID("ahk_exe " . smProcessName)
}
else
{
    smPID := WinGetPID("ahk_exe " . smProcessName)
}

findElement(searchstring, smPID)
ExitApp()
