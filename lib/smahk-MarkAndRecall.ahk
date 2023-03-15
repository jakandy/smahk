; Title:
;   SuperMemo AHK - Mark and Recall module
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
; ************************************* FUNCTIONS ******************************
; ******************************************************************************

; Function name: markCurrentElement
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
markCurrentElement(smPID)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    A_Clipboard := ""
    
    safeActivateElementWindow(smPID)
    Send("^{g}")
    WinWaitActive("ahk_class TInputDlg")
    Send("^{c}")
    
    if !ClipWait(1, 0)
    {
        ; Unable to get element number
        markedElement := ""
    }
    else
    {
        markedElement := A_Clipboard
        Send("{Esc}")
        WinWaitNotActive("ahk_class TInputDlg")
    }
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    Return markedElement
}

; Function name: recallMarkedElement
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
recallMarkedElement(elementnr, smPID)
{
    safeActivateElementWindow(smPID)
    Send("^{g}")
    WinWaitActive("ahk_class TInputDlg")
    
    Send(elementnr)
    Send("{Enter}")
    WinWaitNotActive("ahk_class TInputDlg")
    
    Return
}