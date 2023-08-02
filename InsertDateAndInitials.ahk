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
compiledGitTag := "v1.3.0" ; Added Date Formats

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
	;GUI Creation
	EditDateTimeFormat:
		Gui, FormatPicker:New, -SysMenu

		Gui, FormatPicker: Add, Text, w200, Example Date: January 3rd, 2003
		Gui, FormatPicker: Add, Text, w200, ; Add Spacing    
		; No Weekday
		Gui, FormatPicker:Add, Text, w200, No Weekday:
		Gui, FormatPicker:Add, Button, w200 gSelectFormat01, 01/03 ; MM/yy
		Gui, FormatPicker:Add, Button, w200 gSelectFormat02, 01/2003 ; MM/yyyy
		Gui, FormatPicker:Add, Button, w200 gSelectFormat03, 01/02/03 ; MM/dd/yy
		Gui, FormatPicker:Add, Button, w200 gSelectFormat04, 01/02/2003 ; MM/dd/yyyy

		Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
		; Weekday Short
		Gui, FormatPicker:Add, Text, w200, Weekday Short:
		Gui, FormatPicker:Add, Button, w200 gSelectFormat05, 01/02 Fri ; MM/dd ddd
		Gui, FormatPicker:Add, Button, w200 gSelectFormat07, 01/02/03 Fri (Default) ;MM/dd/yy ddd
		Gui, FormatPicker:Add, Button, w200 gSelectFormat08, 01/02/2003 Fri ;MM/dd/yyyy ddd

		Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
		; Weekday Long
		Gui, FormatPicker:Add, Text, w200, Weekday Long:
		Gui, FormatPicker:Add, Button, w200 gSelectFormat09, 01/02 Friday ;MM/dd dddd
		Gui, FormatPicker:Add, Button, w200 gSelectFormat11, 01/02/03 Friday ;MM/dd/yy dddd
		Gui, FormatPicker:Add, Button, w200 gSelectFormat12, 01/02/2003 Friday ;MM/dd/yyyy dddd

		Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
		; Month Written, No Weekday
		Gui, FormatPicker:Add, Text, w200, Month Written, No Weekday:
		Gui, FormatPicker:Add, Button, w200 gSelectFormat13, Jan 02. ;MMM dd.
		Gui, FormatPicker:Add, Button, w200 gSelectFormat14, Jan 02 ;MMM dd
		Gui, FormatPicker:Add, Button, w200 gSelectFormat15, January 02 ;MMMM dd FLIP 15, 16
		Gui, FormatPicker:Add, Button, w200 gSelectFormat16, January 02, 2003 ;MMMM dd, yyyy FLIP 15, 16
		
		Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
		; Full Dates
		Gui, FormatPicker:Add, Text, w200, Full Date:
		Gui, FormatPicker:Add, Button, w200 gSelectFormat17, Friday, January 02, 2003 ;dddd, MMMM dd, yyyy
		
		Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
		; Cancel Function
		Gui, FormatPicker:Add, Button, w100 gCancelFormat, Cancel
		Gui, FormatPicker:Show, , Pick a DateTime Format
	return

	;Load Selected Update into Variable for UpdateDateTimeFormat function to use. 
	SelectFormat01:
		UpdateDateTimeFormat("MM/yy")
	return
			
	SelectFormat02:
		UpdateDateTimeFormat("MM/yyyy")
	return

	SelectFormat03:
		UpdateDateTimeFormat("MM/dd/yy")
	return

	SelectFormat04:
		UpdateDateTimeFormat("MM/dd/yyyy")
	return

	SelectFormat05:
		UpdateDateTimeFormat("MM/dd ddd")
	return

	SelectFormat06:
		UpdateDateTimeFormat("MM/yyyy ddd")
	return

	SelectFormat07:
		UpdateDateTimeFormat("MM/dd/yy ddd")
	return

	SelectFormat08:
		UpdateDateTimeFormat("MM/dd/yyyy ddd")
	return

	SelectFormat09:
		UpdateDateTimeFormat("MM/dd dddd")
	return

	SelectFormat10:
		UpdateDateTimeFormat("MM/yyyy dddd")
	return

	SelectFormat11:
		UpdateDateTimeFormat("MM/dd/yy dddd")
	return

	SelectFormat12:
		UpdateDateTimeFormat("MM/dd/yyyy dddd")
	return

	SelectFormat13:
		UpdateDateTimeFormat("MMM dd.")
	return

	SelectFormat14:
		UpdateDateTimeFormat("MMM dd")
	return

	SelectFormat15:
		UpdateDateTimeFormat("MMMM dd")
	return

	SelectFormat16:
		UpdateDateTimeFormat("MMMM dd, yyyy")
	return

	SelectFormat17:
		UpdateDateTimeFormat("dddd, MMMM dd, yyyy")
	return

	CancelFormat:
		Gui, FormatPicker:Destroy
	return


; Execute Update to Variable and Preview
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