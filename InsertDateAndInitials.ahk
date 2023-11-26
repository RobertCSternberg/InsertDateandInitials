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
compiledGitTag := "v1.5.0" ; Resolves #28

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

; Set GUI colors for dark theme, margin, and font
Gui,Main: Margin, 10, 10
Gui,Main: Font, s10 cWhite, Arial ;
Gui,Main: Color, 1E1E1E, F1F1F1 ; This sets the background to a dark gray and text to a light gray

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
Gui,Main: Show, , Date and Initials Helper
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


;Edit Initials function
	EditInitials:
		; Apply Dark theme
		Gui, InitialsEditor: New, -SysMenu
		Gui, InitialsEditor: Margin, 10, 10
		Gui, InitialsEditor: Font, s10 cWhite, Arial ;
		Gui, InitialsEditor: Color, 1E1E1E; This sets the background to a dark gray and text to a light gray
		Gui, InitialsEditor: +AlwaysOnTop	
		Gui, InitialsEditor: Add, Text, , Enter your initials:
		Gui, InitialsEditor: Add, Edit, vNewInitials w200 cBlack
		Gui, InitialsEditor: Add, Button, gUpdateInitials w200, OK
		Gui, InitialsEditor: Add, Button, gCancelEdit w200, Cancel
		Gui, InitialsEditor: Show, , Update Initials
	return

	; Execute Update to Variable and Preview
	UpdateInitials:
		Gui, InitialsEditor: Submit
		if (NewInitials <> "")
		{
			global vInitials
			global IniFileName
			NewInitials := Trim(NewInitials)
			StringUpper, NewInitials, NewInitials ; Convert to uppercase using StringUpper
			NewInitials := "[" . NewInitials . "]" ; Surround with square brackets
			vInitials := NewInitials
			IniWrite, %vInitials%, %IniFileName%, Settings, Initials
			Gosub, UpdatePreview
			Gui, InitialsEditor:Destroy
		}
	return

	; Cancel Edit
	CancelEdit:
		Gui, InitialsEditor:Destroy
	return

	
	
; Edit DateTimeFormat function
; GUI Creation
EditDateTimeFormat:
    ; Set GUI colors for dark theme, margin, font, and remove system menu actions of Minimize, Maximize and Close.
    Gui, FormatPicker: New, -SysMenu
    Gui, FormatPicker: Margin, 10, 10
    Gui, FormatPicker: Font, s10 cWhite, Arial
    Gui, FormatPicker: Color, 1E1E1E, F1F1F1 ; This sets the background to a dark gray and text to a light gray

    Gui, FormatPicker: Add, Text, w200, Example Date: 
    Gui, FormatPicker: Add, Text, w200, January 2nd, 2003  ; Updated example date
    ; Add Section
    Gui, FormatPicker: Add, Text, w200 Center, ________________________
    ;Gui, FormatPicker: Add, Text, w200, ; Add Spacing    
    ; No Weekday
    Gui, FormatPicker:Add, Text, w200, No Weekday:
    Gui, FormatPicker:Add, Button, w200 gSelectFormat01, 01/03 (month/year) ; MM/yy
	Gui, FormatPicker:Add, Button, w200 gSelectFormat18, 01/02 (month/day) ; MM/dd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat02, 01/2003 ; MM/yyyy
    Gui, FormatPicker:Add, Button, w200 gSelectFormat03, 01/02/03 ; MM/dd/yy
    Gui, FormatPicker:Add, Button, w200 gSelectFormat04, 01/02/2003 ; MM/dd/yyyy

    Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
    ; Weekday Short
    Gui, FormatPicker:Add, Text, w200, Weekday Short:
    Gui, FormatPicker:Add, Button, w200 gSelectFormat05, 01/02 Thu ; MM/dd ddd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat07, 01/02/03 Thu ; MM/dd/yy ddd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat08, 01/02/2003 Thu ; MM/dd/yyyy ddd

    Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
    ; Weekday Long
    Gui, FormatPicker:Add, Text, w200, Weekday Long:
    Gui, FormatPicker:Add, Button, w200 gSelectFormat09, 01/02 Thursday ; MM/dd dddd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat11, 01/02/03 Thursday ; MM/dd/yy dddd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat12, 01/02/2003 Thursday ; MM/dd/yyyy dddd

    Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
    ; Month Written, No Weekday
    Gui, FormatPicker:Add, Text, w200, Month Written, No Weekday:
    Gui, FormatPicker:Add, Button, w200 gSelectFormat13, Jan 02. ; MMM dd.
    Gui, FormatPicker:Add, Button, w200 gSelectFormat14, Jan 02 ; MMM dd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat15, January 02 ; MMMM dd
    Gui, FormatPicker:Add, Button, w200 gSelectFormat16, January 02, 2003 ; MMMM dd, yyyy

    Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
    ; Full Dates
    Gui, FormatPicker:Add, Text, w200, Full Date:
    Gui, FormatPicker:Add, Button, w200 gSelectFormat17, Thursday, January 02, 2003 ; dddd, MMMM dd, yyyy

    Gui, FormatPicker: Add, Text, w200 , ; Add Spacing
    ; Cancel Function
    Gui, FormatPicker:Add, Button, w200 gCancelFormat Center, Cancel
    Gui, FormatPicker:Show, , Update Date Format
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
	
	SelectFormat18:
		UpdateDateTimeFormat("MM/dd")
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
