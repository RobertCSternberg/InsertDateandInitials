; ===== Standard AHK ==================================================================================================

; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv

; Enable warnings to assist with detecting common errors.
#Warn

; Recommended for new scripts due to its superior speed and reliability.
SendMode Input

; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

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

; ===== GUI Creation ==================================================================================================

; Margin and Font
Gui, Margin, 10, 10
Gui, Font, s10, Arial3

; Add usage instructions
Gui, Add, Text, w300, Use the hotkey "Ctrl + d" to send the current date and time along with your initials.

; Add Initial Setup
Gui, Add, Text, w300 gEditInitials vCurrentInitials, Initials: %vInitials%

; Add Initial Setup
Gui, Add, Text, w300 gEditDateTimeFormat vCurrentDateTimeFormat, Current Date Time Format: %vDateTimeFormat%

; Add Edit Initials button
Gui, Add, Button, w300 gEditInitials, Edit Initials

; Add Edit DateTimeFormat button
Gui, Add, Button, w300 gEditDateTimeFormat, Edit Datetime Format

; Add Hide to Tray button
Gui, Add, Button, w300 gHideToTray, Hide to Tray

; Add help button
Gui, Add, Button, w300 gShowHelp, Help

; Add help button
Gui, Add, Button, w300 gResettoDefault, Reset to Default

; Show the GUI
Gui, Show
Return

; ===== Called from Main GUI ==================================================================================================

; Show help dialog when requested
ShowHelp:
	MsgBox Usage Instructions:`n`n1. Use the Edit Initials Button to set your initials.`n2. Use the hotkey "Ctrl + d" to send the current date and time along with your initials.
	Return

; Minimize to tray function
HideToTray:
	WinHide, A
	return
	
; Exit the script when the GUI is closed
GuiClose:
	ExitApp
	Return

; Edit Initials function
EditInitials:
    Gui, Submit, NoHide
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
        GuiControl, Text, CurrentInitials, Initials: %vInitials% ; Update the GUI label with the new initials
    }
    return
	
; Edit DateTimeFormat function
EditDateTimeFormat:
    Gui, Submit, NoHide
    InputBox, editedDateTimeFormat, Edit DateTimeFormat, Enter your Date Time Format:, , , , , %vDateTimeFormat%
	if (ErrorLevel) ; Check if the user pressed the Cancel button
        return ; If canceled, do nothing
		
    if (editedDateTimeFormat <> "")
    {
        editedDateTimeFormat := Trim(editedDateTimeFormat)
        vDateTimeFormat := editedDateTimeFormat
        IniWrite, %vDateTimeFormat%, %IniFileName%, Settings, DateTimeFormat
        GuiControl, Text, CurrentDateTimeFormat, Current Date Time Format: %vDateTimeFormat% ; Update the GUI label with the new DateTimeFormat
    }
    return

; Reset Initials and DateTimeFormat to default values. 
ResettoDefault:
	;Reset DateTimeFormat
	vDateTimeFormat := "MM/dd/yy ddd"
	IniWrite, %vDateTimeFormat%, %IniFileName%, Settings, DateTimeFormat
    GuiControl, Text, CurrentDateTimeFormat, Current Date Time Format: %vDateTimeFormat% ; Update the GUI label with the new DateTimeFormat
	
	;Reset Initials
	vInitials := "[]"
    IniWrite, %vInitials%, %IniFileName%, Settings, Initials
    GuiControl, Text, CurrentInitials, Initials: %vInitials% ; Update the GUI label with the new initials	
	return
	
	
; ===== Called from Tray ==================================================================================================

; Show GUI from tray function
GoToShowGUI:
	Gui, Show
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
	SendInput %vCurrentDateTimeFormat%
	SendInput {Space}
	Send, %vInitials%:
	SendInput {Space}
Return
