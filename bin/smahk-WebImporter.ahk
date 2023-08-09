; Title:
;   SuperMemo AHK - Web Importer module
;
; Version:
;   1.0.1, 08/2023
;
; Author:
;   andyjak
; 
; Description:
;   A module that is part of the smahk script. It adds the functionality to
;   import web articles into SuperMemo using any web browser the user has
;   specified in the smahk configuration.
;
; Usage:
;   This script is meant to be executed from the main script (smahk.ahk)
;   using the Run()-function. When run this script will display a GUI with
;   the options shown below:
;   - Current tab: Imports the current open browser tab
;   - All tabs: Imports all open browser tabs
;   - Priority: Set the priority of the imported article(s)
;   - Insert references: Inserts references for the imported article(s)
;   - Close tab: Closes the browser tab after import
;   - Import to child: Imports the article to the child of the current element
;   - Import link only: Imports only the title and link of the article
;   - Popup message on finish: Shows a messagebox when import is finished
;
; Test setup:
;   - SuperMemo, version 18.05
;   - AutoHotkey, version 2.0.2
;   - Mozilla Firefox, version 102.9.0esr (64-bit)
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
#Include "..\lib\smahk-lib-WebImporter.ahk"

browserPID := WinGetPID("A")
smPID := IniRead("..\smahk-settings.ini", "Settings", "smPID")

; show import options GUI
myGui := Gui(, "SuperMemo AHK Web Importer")
myGui.OnEvent("Escape", ButtonCancel.Bind("Normal", myGui))
myGui.Add("Text", , "Import to SuperMemo:")
ogcRadioUIWebCur := myGui.Add("Radio", "checked vUIWebCur", "&Current tab")
ogcRadioUIWebAll := myGui.Add("Radio", "vUIWebAll", "A&ll tabs")
myGui.Add("Text", , "&Priority:")
myGui.Add("Edit")
ogcUpDownUIprio := myGui.Add("UpDown", "vUIprio Range0-100", "50")
ogcCheckboxUIRef := myGui.Add("Checkbox", "checked vUIRef", "Insert &references")
ogcCheckboxUICloseTab := myGui.Add("Checkbox", "vUICloseTab", "Clo&se tab")
ogcCheckboxUIChild := myGui.Add("Checkbox", "vUIChild", "Import to c&hild")
ogcCheckboxUIOnlyLink := myGui.Add("Checkbox", "vUIOnlyLink", "Import lin&k only")
ogcCheckboxUIPopup := myGui.Add("Checkbox", "vUIPopup", "Pop&up message on finish")
ogcButtonOK := myGui.Add("Button", "default xm", "&OK")
ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
ogcButtonCancel := myGui.Add("Button", "x+m", "C&ancel")
ogcButtonCancel.OnEvent("Click", ButtonCancel.Bind("Normal"))
myGui.Show()

ButtonOK(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit()
    
    if (oSaved.UIWebCur == 1)
    {
        importCurrentBrowserTab(oSaved.UIRef, oSaved.UIOnlyLink, oSaved.UIChild, oSaved.UICloseTab, oSaved.UIprio, browserPID, smPID)
    }
    else
    if (oSaved.UIWebAll == 1)
    {
        importAllBrowserTabs(oSaved.UIRef, oSaved.UIOnlyLink, oSaved.UIChild, oSaved.UICloseTab, oSaved.UIprio, browserPID, smPID)
    }
    else
    {
        MsgBox("No choice selected.", "Error!", 0)
        ExitApp()
    }
    
    Sleep(500)
    if (oSaved.UIPopup == 1)
        MsgBox("Import has finished.", "Success!", 0)

    ExitApp()
}

ButtonCancel(A_GuiEvent, GuiCtrlObj, Info, *)
{
    ExitApp()
}
