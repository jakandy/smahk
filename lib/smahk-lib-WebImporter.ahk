; Title:
;   SuperMemo AHK - Web Importer module
;
; Version:
;   v1.0.0, 03/2023
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
; Tested with:
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
#Include "smahk-lib.ahk"

; ******************************************************************************
; ************************************* FUNCTIONS ******************************
; ******************************************************************************

; Function name: importBrowserTab
; --------------------
;
; Description:
;   Imports the contents of a browser tab to SuperMemo through copy-paste.
;   Beware, overwrites the content of the clipboard!
;
; Input parameter:
;   ref - Set to true if references shall be inserted
;   onlyLink - Set to true if only link shall be imported
;   importToChild - Set to true if importing to a child topic
;   prio - the priority of the imported article
;   browserPID - the process ID of the running web browser
;   smPID - the process ID of the SuperMemo process that has the collection open
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
        if ( !ClipWait(3, 0) )
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
        WinWaitNotActive(prevEl)
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
        waitTextCursor(start_CaretX, start_CaretY)
		WinWaitActive("ahk_class TElWind ahk_pid " smPID)
        
        ; Insert references
        if (ref == true)
        {
            setRef(refsMerged, false, smPID)
            Sleep(100)
        }
        
        ; set title
        Send("^+{p}")
        WinWaitActive("ahk_class TElParamDlg ahk_pid " smPID)
        Send("{TAB 3}")
        A_Clipboard := ""
        A_Clipboard := elementTitle
        if ( !ClipWait(1, 0) )
        {
            MsgBox("Clipboard failure.", "Error!", 0)
            return
        }
        safePasteText()
        Send("{enter}")
    }
    else
    if (onlyLink == true)
    {
        ; import link
        A_Clipboard := SubStr(refs[1], 9)
        if ( !ClipWait(1, 0) )
        {
            MsgBox("Clipboard failure.", "Error!", 0)
            return
        }
        safePasteText()
        setRef(refsMerged, false, smPID)
    }
    
    setPriority(prio, smPID)    
    safeActivateElementWindow(smPID)
    
    if (importToChild == true)
    {
        ; go back to parent
        childTitle := WinGetTitle("A")
        Send("^{up}")
        WinWaitNotActive(childTitle)
    }
    
    ; Window switch to web browser
    WinActivate("ahk_pid " browserPID)
    while ( !WinWaitActive("ahk_pid " browserPID,, 1) )
    {
        WinActivate("ahk_pid " browserPID)
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
;   prio - the priority of the imported article
;   browserPID - the process ID of the running web browser
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
importCurrentBrowserTab(ref, onlyLink, importToChild, closeTab, prio, browserPID, smPID)
{
    if (WinActive("ahk_pid " . browserPID) == 0)
    {
        WinActivate("ahk_pid " browserPID)
        WinWaitActive("ahk_pid " browserPID)
    }
    
    ; Save contents of clipboard
    ClipSaved := ClipboardAll()

    importBrowserTab(ref, onlyLink, importToChild, prio, browserPID, smPID)
    if (closeTab == true)
    {
        previousTabTitle := WinGetTitle("A")
        Send("^{w}")
        WinWaitNotActive(previousTabTitle)
    }

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    return
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
;   prio - the priority of the imported article
;   browserPID - the process ID of the running web browser
;   smPID - the process ID of the SuperMemo process that has the collection open
;
; Return:
;   ---
;
importAllBrowserTabs(ref, onlyLink, importToChild, closeTab, prio, browserPID, smPID)
{
    if (WinActive("ahk_pid " . browserPID) == 0)
    {
        WinActivate("ahk_pid " browserPID)
        WinWaitActive("ahk_pid " browserPID)
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
        
        WinWaitNotActive(previousTabTitle)
    }

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
    
    return
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
        if ( !ClipWait(1, 0) )
        {
            MsgBox("Clipboard failure.", "Error!", 0)
            return
        }
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
        WinWaitActive(wTitle)
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
;   browserPID - the process ID of the running web browser
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
            WinWaitNotActive(activeTabName)
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
;   tabCount - contains the number of tabs
;
getTabCount()
{
    first_title := WinGetTitle("A")
    current_title := first_title

    Loop
    {
        Send("^{tab}")
        ErrorLevel := WinWaitNotActive(current_title,, 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
        current_title := WinGetTitle("A")
        
        if ( (ErrorLevel != 0) OR (current_title == first_title) )
        {
            tabCount := A_Index
            break
        }
        
    }
    
    Return tabCount
}

