; Title:
;   SuperMemo AHK - Configuration module
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
#Include <smahk-lib>         ; Custom subroutines used in the script.

; ******************************************************************************
; ********************************* MAIN PROGRAM START *************************
; ******************************************************************************
; TODO: add options for changing keyboard bindings

if not FileExist("smahk-settings.ini")
    FileAppend("", "smahk-settings.ini")

knoPath := IniRead("smahk-settings.ini", "Settings", "knoPath", "ERROR")
if (knoPath == "ERROR")
    knoPath := ""

browserPath := IniRead("smahk-settings.ini", "Settings", "browserPath", "ERROR")
if (browserPath == "ERROR")
    browserPath := ""

; show import options GUI
myGui := Gui(, "SuperMemo AHK Configuration")
myGui.OnEvent("Escape", ButtonCancel.Bind("Normal", myGui))
myGui.Add("Text", "xm", "SuperMemo Collection path:")
ogcEditUIknoPath := myGui.Add("Edit", "r1 vUIknoPath w135", knoPath)
ogcButtonBrowse := myGui.Add("Button", "x+m", "Browse")
ogcButtonBrowse.OnEvent("Click", BtnSM.Bind("Normal"))
myGui.Add("Text", "xm", "Web browser path:")
ogcEditUIBrowserPath := myGui.Add("Edit", "r1 vUIBrowserPath w135", browserPath)
ogcButtonBrowse := myGui.Add("Button", "x+m", "Browse")
ogcButtonBrowse.OnEvent("Click", BtnWeb.Bind("Normal"))
ogcButtonOK := myGui.Add("Button", "default xm", "OK")
ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
ogcButtonCancel := myGui.Add("Button", "x+m", "Cancel")
ogcButtonCancel.OnEvent("Click", ButtonCancel.Bind("Normal"))
myGui.Show()

BtnSM(A_GuiEvent, GuiCtrlObj, Info, *)
{
    knoPath := FileSelect("", "", "Select the SuperMemo collection you want to use with smahk", "Knowledge collection (*.kno)")
    ogcEditUIknoPath.Value := knoPath
    return
}
    
BtnWeb(A_GuiEvent, GuiCtrlObj, Info, *)
{
    browserPath := FileSelect("", "", "Select the executable of the web browser to use for SuperMemo imports", "Executable (*.exe)")
    ogcEditUIBrowserPath.Value := browserPath
    return
}

ButtonOK(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit()
    IniWrite(oSaved.UIknoPath, "smahk-settings.ini", "Settings", "knoPath")
    IniWrite(oSaved.UIBrowserPath, "smahk-settings.ini", "Settings", "browserPath")
    
    if (oSaved.UIknoPath != "")
        smProcessName := "sm18.exe"
    else
        smProcessName := ""
    IniWrite(smProcessName, "smahk-settings.ini", "Settings", "smProcessName")
    
    if (oSaved.UIBrowserPath != "")
        browserProcessName := SubStr(oSaved.UIBrowserPath, InStr(oSaved.UIBrowserPath,"\",,-1)+1)
    else
        browserProcessName := ""
    IniWrite(browserProcessName, "smahk-settings.ini", "Settings", "browserProcessName")
    
    ExitApp()
}

ButtonCancel(A_GuiEvent, GuiCtrlObj, Info, *)
{
    ExitApp()
}