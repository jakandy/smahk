﻿; Title:
;   SuperMemo AHK - Web Importer module
;
; Version:
;   v1.00, 09/2022
;
; Author:
;   andyjak
; 
; Description:
;   This file contains a GUI used for importing web articles into SuperMemo.
;   Many functions here uses the PostMessage function and some
;   wParam argument values changes between SuperMemo versions. 
;   This means that most functions will probably only work for the
;   version of SuperMemo listed in the requirements section below.
;   To update the functions for other versions, new wParam values need to
;   be found using a software like Spy++.
;
; Usage:
;   Place this file in the same folder as "smahk.ahk".
;   When run this script will display a GUI where a user can choose
;   options to import articles.
;
; Tested with:
;   - SuperMemo 18.05
;   - AutoHotkey, version 2.0.2
;   - Windows 10
;   - Mozilla Firefox, version 102.5.0
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

; ******************************************************************************
; ********************************** MAIN PROGRAM END **************************
; ******************************************************************************

; ******************************************************************************
; ************************************* FUNCTIONS ******************************
; ******************************************************************************

; Function name: importBrowserTab
; --------------------
;
; Description:
;   Imports a browser tab to SuperMemo through copy-paste.
;   Beware, overwrites the content of the clipboard!
;
; Input parameter:
;   ref - Set to true if references shall be inserted
;   onlyLink - Set to true if only link shall be imported
;   importToChild - Set to true if importing to a child topic
;   browserPID - integer containing the process ID of the web browser
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
importBrowserTab(ref, onlyLink, importToChild, prio, browserPID, smPID)
{
    if (onlyLink == false)
    {
        ; get article title (to fix it later)
        windowTitle := WinGetTitle("A")
        shortDashPos := InStr(windowTitle, " - ", , (StartingPos := -1)<1 ? (StartingPos := -1)-1 : (StartingPos := -1))
        longDashPos := InStr(windowTitle, " — ", , (StartingPos := -1)<1 ? (StartingPos := -1)-1 : (StartingPos := -1))
        trimLength := max(shortDashPos, longDashPos)
        if (trimLength > 1)
            elementTitle := SubStr(windowTitle, 1, trimLength - 1)
        else
            elementTitle := windowTitle
        
        ; Copy web page
        Send("^{a}")
        A_Clipboard := ""
        Send("^{c}")
        Errorlevel := !ClipWait(3, 0)
        if (ErrorLevel != 0)
        {
            MsgBox("Unable to copy contents of webpage.", "Error!", 0)
            Return
        }
    }
    
    ; Get reference data
    if ( (ref == true) OR (onlyLink == true) )
    {
        refs := getRef(true, true, true)
        refsMerged := refs[1] "`n" refs[2] "`n" refs[3] "`n"
    }

    ; Window switch to SM
    Sleep(50)
    safeActivateElementWindow(smPID)

    ; Create new topic
    if (importToChild == true)
    {
        createNewChildTopic(false, smPID)
    }
    else
    {
        prevEl := WinGetTitle("A")
        Send("!{n}")
        waitElement(prevEl, smPID)
    }

    if (onlyLink == false)
    {
        ; import HTML
        ; Paste page contents
        safePasteText()
        
        ; Filter HTML
        CaretFound := CaretGetPos(&start_CaretX, &start_CaretY)
        while (CaretFound == 0)
        {
            CaretFound := CaretGetPos(&start_CaretX, &start_CaretY)
            Sleep(50)
        }
        Send("{f6}")
        while ( (WinActive("ahk_class TChecksDlg") == 0) AND (WinActive("ahk_class TMsgDialog") == 0) )
            Sleep(50)
        Send("{Enter}")
        waitTextCursor(start_CaretX, start_CaretY)  ; used for knowing when filtering done
        Sleep(50)
        
        ; Insert references
        if (ref == true)
            setRef(refsMerged, false, smPID)
        
        ; set title
        Send("^+{p}")
        ErrorLevel := WinWaitActive("ahk_class TElParamDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("{esc}")
        ErrorLevel := WinWaitNotActive("ahk_class TElParamDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        PostMessage(0x0111, 116, , , "ahk_class TElWind ahk_pid " smPID)
        A_Clipboard := ""
        A_Clipboard := elementTitle
        Errorlevel := !ClipWait(1, 0)
        ErrorLevel := WinWaitActive("ahk_class TChoicesDlg ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        Send("{enter}")
        ErrorLevel := WinWaitActive("ahk_class TTitleEdit ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        safePasteText()
        Send("{enter}")
    }
    else
    if (onlyLink == true)
    {
        ; import link
        A_Clipboard := SubStr(refs[1], 9)
        Errorlevel := !ClipWait(1, 0)
        safePasteText()
        setRef(refsMerged, false, smPID)
    }
    
    setPriority(prio, smPID)
    
    if (WinActive("ahk_class TElWind") == 0)
    {
        WinActivate("ahk_pid " smPID)
        ErrorLevel := WinWaitActive("ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        WinActivate("ahk_class TElWind ahk_pid " smPID)
        ErrorLevel := WinWaitActive("ahk_class TElWind ahk_pid " smPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    
    if (importToChild == true)
    {
        ; go back to parent
        childTitle := WinGetTitle("A")
        Send("^{up}")
        waitElement(childTitle, smPID)
    }
    
    ; Window switch to web browser
    WinActivate("ahk_pid " browserPID)
    ErrorLevel := WinWaitActive("ahk_pid " browserPID, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    while (ErrorLevel != 0)
    {
        WinActivate("ahk_pid " browserPID)
        ErrorLevel := WinWaitActive("ahk_pid " browserPID, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    
    Return
    
}


; Function name: importCurrentBrowserTab
; --------------------
;
; Description:
;   Imports the current tab in the web browser to SuperMemo.
;
; Input parameter:
;   ref - Set to true if references shall be inserted
;   onlyLink - Set to true if only link shall be imported
;   importToChild - Set to true if importing to a child topic
;   closeTab - Set to true if tab shall be closed after import
;   browserPID - integer containing the process ID of the web browser
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
importCurrentBrowserTab(ref, onlyLink, importToChild, closeTab, prio, browserPID, smPID)
{
    if (WinActive("ahk_pid " . browserPID) == 0)
    {
        WinActivate("ahk_pid " browserPID)
        ErrorLevel := WinWaitActive("ahk_pid " browserPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()

    importBrowserTab(ref, onlyLink, importToChild, prio, browserPID, smPID)
    if (closeTab == true)
    {
        previousTabTitle := WinGetTitle("A")
        Send("^{w}")
        ErrorLevel := WinWaitNotActive(previousTabTitle) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
}


; Function name: importAllBrowserTabs
; --------------------
;
; Description:
;   Imports all open tabs in the browser to SuperMemo.
;
; Input parameter:
;   ref - Set to true if references shall be inserted
;   onlyLink - Set to true if only link shall be imported
;   importToChild - Set to true if importing to a child topic
;   closeTab - Set to true if tab shall be closed after import
;   browserPID - integer containing the process ID of the web browser
;   smPID - integer containing the process ID of SuperMemo
;
; Return:
;   ---
;
importAllBrowserTabs(ref, onlyLink, importToChild, closeTab, prio, browserPID, smPID)
{
    if (WinActive("ahk_pid " . browserPID) == 0)
    {
        WinActivate("ahk_pid " browserPID)
        ErrorLevel := WinWaitActive("ahk_pid " browserPID) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    
    tabCount := getTabCount()

    Loop tabCount
    {
        importBrowserTab(ref, onlyLink, importToChild, prio, browserPID, smPID)
        previousTabTitle := WinGetTitle("A")
        if (closeTab == true)
            Send("^{w}")
        else
            Send("^{tab}")
        
        ErrorLevel := WinWaitNotActive(previousTabTitle) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
}


; Function name: getRef
; --------------------
;
; Description:
;   Gets data from the active window and outputs a string to be inserted as
;   reference in a topic.
;   The application name is automatically omitted.
;
; Input parameter:
;   refTitle - bool to control if title ref should be extracted
;   refDate - bool to control if date ref should be extracted
;   refLink - bool to control if link ref should be extracted
;
; Return:
;   refs - array containing the reference strings in each element
;
getRef(refTitle, refDate, refLink)
{
    refs := Array()
    refs.Length := 3

    ; Title reference
    if (refTitle == true)
    {
        windowTitle := WinGetTitle("A")
        ; TODO: change to a general method to trim browser title
        trimTitle := SubStr(windowTitle, 1, -18) ; -18 for trimming the string: " - Mozilla Firefox"
        refs[1] := "#Title: " . trimTitle
    }
    else
        refs[1] := 0

    ; Time and date reference
    if (refDate == true)
    {
        currentTime := FormatTime("A_Now", "MMM d, yyyy, HH:mm:ss")
        refs[2] := "#Date: Imported on " . currentTime
    }
    else
        refs[2] := 0
    
    ; Link reference
    if (refLink == true)
    {
        ; Save contents of clipboard
        ClipSaved := ClipboardAll()
    
        Send("^{l}")
        Sleep(50)
        A_Clipboard := ""
        Send("^{c}")
        Errorlevel := !ClipWait(1, 0)
        Send("{f6}")
        refs[3] := "#Link: " . A_Clipboard
        
        ; Restore clipboard
        A_Clipboard := ClipSaved
        ClipSaved := ""
    
        Sleep(50)
    }
    else
        refs[3] := 0

    Return refs
}

; Function name: getCurrentBrowserTabURL
; --------------------
;
; Description:
;   Gets the URL from the current browser tab.
;
; Input parameter:
;   wTitle - WinTitle of active window
;
; Return:
;   url - String containing the URL of the current tab
;
getCurrentBrowserTabURL(wTitle)
{
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()
    safeCopyToClipboard("")
    
    if (WinActive(wTitle) == 0)
    { 
        WinActivate(wTitle)
        ErrorLevel := WinWaitActive(wTitle) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
    }
    
    while ( (A_Clipboard == "") AND (ErrorLevel != 0) )
    {
        Send("^{l}")
        Send("^{c}")
        Errorlevel := !ClipWait(1, 0)
        Sleep(50)
    }
    
    url := A_Clipboard
    
    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    return url
}


; Function name: getAllBrowserTabURLs
; --------------------
;
; Description:
;   Traverses each tab in the active web browser and returns the URL as a list.
;
; Input parameter:
;   browserPID - integer containing the process ID of the web browser
;
; Return:
;   url_list - List of urls
;
getAllBrowserTabURLs(browserPID)
{    
    if WinActive("ahk_pid " . browserPID)
    { 
        ; Save contents of clipboard
        ClipSaved := ClipboardAll()
        
        ; Declare variables
        url_list := ""
        first_url := ""
        url := ""
        browserProcessName := WinGetProcessName("ahk_pid " browserPID)

        ; get url from all open browser tabs
        Loop
        {
            url := getCurrentBrowserTabURL("ahk_exe " . browserProcessName)
            MsgBox(url)
            if (url == first_url)
            {
                url_list := SubStr(url_list, 1, StrLen(url_list)-1)
                break
            }
            if (A_Index == 1)
                first_url := url
            url_list .= url "`n"
            activeTabName := WinGetTitle("A")
            Send("^{tab}")
            ErrorLevel := WinWaitNotActive(activeTabName) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        }
        
        ; Restore clipboard
        A_Clipboard := ClipSaved
        ClipSaved := ""
        
        Return url_list
    }
    Return
}


; Function name: getTabCount
; --------------------
;
; Description:
;   Traverses each tab in the active web browser and returns
;   the number of open tabs.
;
; Input parameter:
;   ---
;
; Return:
;   ---
;
getTabCount()
{
    first_title := WinGetTitle("A")
    current_title := first_title

    Loop
    {
        Send("^{tab}")
        ErrorLevel := WinWaitNotActive(current_title, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        current_title := WinGetTitle("A")
        
        if ( (ErrorLevel != 0) OR (current_title == first_title) )
        {
            tabCount := A_Index
            break
        }
        
    }
    
    Return tabCount
}

