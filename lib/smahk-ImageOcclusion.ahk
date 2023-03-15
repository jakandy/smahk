; Title:
;   SuperMemo AHK - Image Occlusion module
;
; Version:
;   v1.00, 03/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It is a library containing functions to
;   be used for creating an image occlusion item from the image component
;   in the current element.
;
; Usage:
;   Place this file in any directory and include it to your script using
;   the #include directive. Then you can call any function as normal.
;   Read the header of each function for more info about
;   what they do and how to use them.
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
#Include "smahk-lib.ahk"         ; Custom subroutines used in the script.


; Function name: imageOcclusion
; --------------------
;
; Description:
;   Creates an image occlusion item based on the image in the current element.
;
; Input parameter:
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
imageOcclusion(smPID)
{
    if (detectImageComponent(smPID) == 0)
        return
    
    ; Duplicate current element and wait until it has been copied
    safeActivateElementWindow(smPID)
    parentName := WinGetTitle("A")
    Send("!{d}")
    waitElement(parentName, smPID)

    ; Find and select the first order image component
    detectImageComponent(smPID)

    ; Set image component to filled
    sendContextMenuCommand(877, smPID)

    ; Convert element to item
    safeActivateElementWindow(smPID)
    sendContextMenuCommand(737, smPID)    
    WinWaitActive("ahk_class TMsgDialog")
    Send("{Enter}")
    WinWaitNotActive("ahk_class TMsgDialog")

    ; Change to occlusion template
    safeActivateElementWindow(smPID)
    Send("^+{m}")
    WinWaitActive("ahk_class TRegistryForm ahk_pid " . smPID)
    Send("occlusion")
    Send("{Enter}")
    WinWaitNotActive("ahk_class TRegistryForm ahk_pid " . smPID)

    ; Impose template (so that components can be edited without affecting other occlusion items)
    safeActivateElementWindow(smPID)
    Send("^+{f2}")
    WinWaitActive("ahk_class TMsgDialog ahk_pid " . smPID)
    Send("{Enter}")
    Sleep(100)
    WinWaitActive("ahk_class TMsgDialog ahk_pid " . smPID)
    Send("{Enter}")
    Return
}

; Function name: detectImageComponent
; --------------------
;
; Description:
;   Detects if there is an image component in the current element.
;   If there is an image component, focus is shifted to that control
;   by opening and closing the "Process images" dialog.
;
; Input parameter:
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   0 - if no component is found
;
detectImageComponent(smPID)
{
    safeActivateElementWindow(smPID)
    Send("^+{f8}")
    while (WinActive("ahk_class TChoicesDlg ahk_pid " . smPID) == 0)
    {
        if (WinActive("ahk_class TMsgDialog ahk_pid " . smPID))
            return 0
        
        Sleep(50)
    }
    Send("{Escape}")
    WinWaitNotActive("ahk_class TChoicesDlg ahk_pid " . smPID)
    return
}