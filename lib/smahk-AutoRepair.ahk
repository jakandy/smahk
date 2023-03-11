; Title:
;   SuperMemo AHK - Auto Repair module
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
;   Place this file in the same directory as the other files for smahk.
;   Add at the top of your script: "#Include smahk-WebImporter.ahk" without
;   quotes. When run this script will display a GUI where a user can choose
;   options to import articles.
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


; ******************************************************************************
; ********************************* MAIN PROGRAM START *************************
; ******************************************************************************
knoPath := IniRead("..\smahk-settings.ini", "Settings", "knoPath")
smProcessName := IniRead("..\smahk-settings.ini", "Settings", "smProcessName")
if ( (knoPath == "ERROR") OR (smProcessName == "ERROR") )
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
WinActivate("ahk_exe " smProcessName)
ErrorLevel := WinWaitActive("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
WinActivate("ahk_class TElWind")
ErrorLevel := WinWaitActive("ahk_class TElWind", , 5) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
if (ErrorLevel != 0)
{
    MsgBox("Blabla", "Error!", 0)
    ExitApp()
}
Sleep(1000)
WinClose("ahk_exe " smProcessName)
ErrorLevel := WinWaitClose("ahk_exe " smProcessName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
Sleep(1000)
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
    Sleep(5000)
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