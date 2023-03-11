; Title:
;   SuperMemo AHK - Backup module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   ---
;
; Usage:
;   ---
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
#Include "smahk-lib.ahk"         ; Custom subroutines used in the script.

; ******************************************************************************
; ********************************* MAIN PROGRAM START *************************
; ******************************************************************************
knoPathKno := IniRead("..\smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if ( (knoPathKno == "ERROR") OR (smProcessName == "ERROR") )
{
    MsgBox("Could not find path to SuperMemo executable.", "Error!", 0)
    ExitApp()
}

SourceFolder := SubStr(knoPathKno, 1, -4)
TargetFolder := SubStr(knoPathKno, 1, InStr(knoPathKno, "\systems\", , -2)) . "backup"

msgResult := MsgBox("The collection in:`n" SourceFolder "`n`nwill be backed up into:`n" TargetFolder ".`n`n(Be aware that SuperMemo will be closed during the process) `n `nContinue?", "SuperMemo AHK Backup", 4)
if (msgResult = "No")
    ExitApp()
    
ErrorLevel := ProcessExist(smProcessName)
if (ErrorLevel != 0)
{
    WinClose("ahk_exe " smProcessName)
    ErrorLevel := WinWaitClose("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    Sleep(1000)
}

SplitPath(SourceFolder, &SourceFolderName)

currentTime := FormatTime("A_Now", "yyyy-MM-dd HH-mm")

; TODO: add a progress bar
Try{
   DirCopy(SourceFolder, TargetFolder "\" currentTime "\" SourceFolderName)
   ErrorLevel := 0
} Catch {
   ErrorLevel := 1
}
Try{
   FileCopy(knoPathKno, TargetFolder "\" currentTime)
   ErrorLevel := 0
} Catch as Err {
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
        Run("smahk.ahk")
}
    
ExitApp()
