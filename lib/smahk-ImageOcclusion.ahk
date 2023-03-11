; Title:
;   SuperMemo AHK - Image Occlusion module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   Library containing functions written in the AutoHotkey scripting language
;   to be used for automating the UI in SuperMemo.
;   This particular library contains various functions that can be used
;   when manipulating elements in SuperMemo.
;   Many functions here uses the PostMessage function and some
;   wParam argument values changes between SuperMemo versions. 
;   This means that most functions will probably only work for the
;   version of SuperMemo listed in the requirements section below.
;   To update the functions for other versions, new wParam values need to
;   be found using a software like Spy++.
;
; Usage:
;   Place this file in the same folder as the script you want to use.
;   Add at the top of your script: "#Include smahk-lib.ahk" without quotes.
;   Call any function in this library like any other function, i.e. 
;   functionName(argument). Read the header of each function for more info
;   about what they do and how to use.
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