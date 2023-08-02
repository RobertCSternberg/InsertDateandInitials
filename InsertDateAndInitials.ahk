; ===== Standard AHK ==================================================================================================

; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv

; Enable warnings to assist with detecting common errors.
#Warn

; Recommended for new scripts due to its superior speed and reliability.
SendMode Input

; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

; ===== Version Information ==================================================================================================
compiledGitTag := "v1.2.0" ; Replace with your current version

; ===== Grab .ini Data, Create if does not exist ==================================================================================================
IniFileName := "Settings_InsertDateAndInitials.ini"
if !FileExist(IniFileName) ; Check if the .ini file does not exist
{
	IniWrite, "", %IniFileName%, Settings, Initials
	IniWrite, MM/dd/yy ddd, %IniFileName%, Settings, DateTimeFormat ; Set default date-time format
}

IniRead, vInitials, %IniFileName%, Settings, Initials
IniRead, vDateTimeFormat, %IniFileName%, Settings, DateTimeFormat

; ===== Setup ==================================================================================================

; Tray Menu
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, GoToShowGUI
Menu, Tray, Add, Exit, TrayExit
Menu, Tray, Default, Show GUI

; ===== GUI Creation ==================================================================================================
; Format the Date for Use in the Preview
FormatTime, vCurrentDateTimeFormat,, %vDateTimeFormat%

; Margin and Font
Gui,Main: Margin, 10, 10
Gui,Main: Font, s10, Arial3

; Add Section
Gui,Main: Add, Text, w300 Center, ________________________________________

; Add Title
Gui,Main: Add, Text, w300 Center, Currently Using:

; Add Preview
Gui,Main: Add, Text, w300 Center vPreview, %vCurrentDateTimeFormat% %vInitials%: 

; Add Section
Gui,Main: Add, Text, w300 Center, ________________________________________

; Add Section
Gui,Main: Add, Text, w300 Center, --- General Setup / Hide to Tray ---

; Add Edit Initials button
Gui,Main: Add, Button, w300 gEditInitials, Edit Initials

; Add Edit Date Format button
Gui,Main: Add, Button, w300 gEditDateTimeFormat, Edit Date Format

; Add Hide to Tray button
Gui,Main: Add, Button, w300 gHideToTray, Hide to Tray

; Add Spacing
Gui,Main: Add, Text, w300 ,

; Add Section
Gui,Main: Add, Text, w300 Center, --- Settings / Help ---

; Add Check for Updates button
Gui,Main: Add, Button, w300 gCheckforUpdates, Check for Updates

; Add Reset button
Gui,Main: Add, Button, w300 gConfirmResettoDefault, Reset to Default

; Add Help button
Gui,Main: Add, Button, w300 gShowHelp, Help

; Add Version Information
Gui,Main: Add, Text, w300 Right, %compiledGitTag%

; Show the GUI
Gui,Main: Show
Return

; ===== Called from Main GUI ==================================================================================================

; Show help dialog when requested
ShowHelp:
	MsgBox Usage Instructions:`n`n1. Use the Edit Initials Button to set your initials.`n2. Use the hotkey "Ctrl + d" to send the current date and time along with your initials.
	Return

; Check for Updates when requested
CheckforUpdates:
    ; Fetch latest tag from GitHub
    latestGitTag := GetLatestGithubTag("RobertCSternberg", "InsertDateandInitials")
    
    if (compiledGitTag != latestGitTag && latestGitTag != "")
    {
        MsgBox New version (%latestGitTag%) available! Contact developer for more information. 
    }
    else if (latestGitTag = "")
    {
        MsgBox Unable to fetch the latest version from GitHub. 
    }
    else
    {
        MsgBox You are using the latest version: %compiledGitTag%.
    }
return

; Minimize to tray function
HideToTray:
	WinHide, A
	return
	
; Exit the script when the GUI is closed
MainGuiClose:
	GoSub, ConfirmExitApp
	Return

; Edit Initials function
EditInitials:
    Gui,Main: Submit, NoHide
    InputBox, editedInitials, Edit Initials, Enter your initials:, , , , , %vInitials%
	if (ErrorLevel) ; Check if the user pressed the Cancel button
        return ; If canceled, do nothing
		
    if (editedInitials <> "")
    {
        editedInitials := Trim(editedInitials)
        StringUpper, editedInitials, editedInitials ; Convert to uppercase using StringUpper
        editedInitials := "[" . editedInitials . "]" ; Surround with square brackets
        vInitials := editedInitials
        IniWrite, %vInitials%, %IniFileName%, Settings, Initials
		Gosub, UpdatePreview
    }
    return
	
; Edit DateTimeFormat function
EditDateTimeFormat:
    Gui, FormatPicker:New, -SysMenu
    Gui, FormatPicker:Add, Button, w200 gSelectFormat1, 01/01/01 Mon
    Gui, FormatPicker:Add, Button, w200 gSelectFormat2, 01/01/2001
    Gui, FormatPicker:Add, Button, w200 gSelectFormat3, 01/01/01 Monday
    Gui, FormatPicker:Add, Button, w100 gCancelFormat, Cancel
    Gui, FormatPicker:Show, , Pick a DateTime Format
    return

SelectFormat1:
    UpdateDateTimeFormat("MM/dd/yy ddd")
    return

SelectFormat2:
    UpdateDateTimeFormat("MM/dd/yyyy")
    return

SelectFormat3:
    UpdateDateTimeFormat("MM/dd/yyyy dddd")
    return

CancelFormat:
    Gui, FormatPicker:Destroy
    return

UpdateDateTimeFormat(newFormat)
{
    global vDateTimeFormat
    global IniFileName
    vDateTimeFormat := newFormat
    IniWrite, %vDateTimeFormat%, %IniFileName%, Settings, DateTimeFormat
	Gosub, UpdatePreview
	Gui, FormatPicker:Destroy
}


; Confirm Reset to Default
ConfirmResetToDefault:
    MsgBox, 4, Reset to Default, Are you sure you want to reset the settings to default? This action cannot be undone.
    IfMsgBox, Yes
    {
        ; The user clicked Yes, so proceed with resetting to default
        GoSub, ResettoDefault
    }
    return
	
; Confirm Exit
ConfirmExitApp:
    MsgBox, 4, Quit?, Are you sure you want to quit the application? `n `nInstead consider hiding to the system tray. This action can be preformed on the main menu with Hide to Tray and will allow you to continue using the hotkey Ctrl+D.
    IfMsgBox, Yes
    {
        ; The user clicked Yes, so proceed to ExitApp
        ExitApp
    }
    return

; Reset Initials and DateTimeFormat to default values. 
	ResettoDefault:
	;Reset DateTimeFormat
	vDateTimeFormat := "MM/dd/yy ddd"
	IniWrite, %vDateTimeFormat%, %IniFileName%, Settings, DateTimeFormat
	
	;Reset Initials
	vInitials := "[]"
    IniWrite, %vInitials%, %IniFileName%, Settings, Initials
	
	;Update the Preview
	Gosub, UpdatePreview
	return
	
;Get Latest Version from GitHub
GetLatestGithubTag(username, repo)
{
    ; Send a request to the GitHub API to get the latest release tag
    url := "https://api.github.com/repos/" . username . "/" . repo . "/releases/latest"
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", url, false)
    whr.setRequestHeader("User-Agent", "AHK Script")
    whr.Send()
    response := whr.ResponseText
    
    ; Check response status
    status := whr["Status"]
    if (status != 200)
    {
		MsgBox Error: Status Code - %status%
        return ""
    }
    
    ; Show the response for debugging
    ; MsgBox %response%
    
    ; Parse the JSON response to get the tag_name
    tagPattern := """tag_name"":\s*""(v?\d+\.\d+\.\d+)"""
    
    if (RegExMatch(response, tagPattern, match))
    {
        return match1 ; returns the version number
    }
    
    ; Return empty if unable to fetch the tag (handle this gracefully in the main script)
    return ""
}
	
; ===== Called from Tray ==================================================================================================

; Show GUI from tray function
GoToShowGUI:
	Gui,Main: Show
return

; Tray Exit
TrayExit:
	ExitApp
return
		
; ===== Hotkey Pressed ==================================================================================================

; Hotkey for sending the current date and time
^d::

	; Format the current date and time using the selected format
	FormatTime, vCurrentDateTimeFormat,, %vDateTimeFormat%
	
	; Send the formatted date and time
	Send, %vCurrentDateTimeFormat% %vInitials%: 
	SendInput {Space}
return 

; ===== Update Preview ==================================================================================================

UpdatePreview:
	; Format the current date and time using the selected format
	FormatTime, vCurrentDateTimeFormat,, %vDateTimeFormat%
	
	; Update the main GUI label with the new preview
	GuiControl, Main: Text, Preview, %vCurrentDateTimeFormat% %vInitials%: 
return 