; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv

; Enable warnings to assist with detecting common errors.
;#Warn

; Recommended for new scripts due to its superior speed and reliability.
SendMode Input

; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

; Format the current date and time into different formats
FormatTime, exampleMMddyydddcurrentDateTime,, MM/dd/yy ddd
FormatTime, exampleMMddyycurrentDateTime,, MM/dd/yy
FormatTime, exampleMMddyyyycurrentDateTime,, MM/dd/yyyy

; GUI Creation
Gui, Margin, 10, 10
Gui, Font, s10, Arial3

; Add usage instructions
Gui, Add, Text, , Usage Instructions:
Gui, Add, Text, , 1. Enter your initials in the "Initials" field
Gui, Add, Text, , 2. Select the desired date and time format from the radio buttons
Gui, Add, Text, , 3. Use the hotkey "Ctrl + d" to send the current date and time along with your initials.

;Add Initial Setup
Gui, Add, Text, , Initials:
Gui, Add, Edit, vInitials, []


; Add three radio buttons with different date and time formats as their label
Gui, Add, Radio, altsubmit gCheck vradioGroup, %exampleMMddyydddcurrentDateTime%
Gui, Add, Radio, altsubmit gCheck, %exampleMMddyycurrentDateTime%
Gui, Add, Radio, altsubmit gCheck, %exampleMMddyyyycurrentDateTime%


; Show the GUI
Gui, Show
Return

; Exit the script when the GUI is closed
GuiClose:
ExitApp

; Check function triggered by selecting a radio button
Check:
GuiControlGet, vInitials, , Edit1
Gui, Submit, NoHide
;MsgBox, radioGroup = %radioGroup%
;MsgBox, radioGroup = %vInitials%


; Hotkey for sending the current date and time
^d::

; If the first radio button is selected
if (radioGroup = 1){

FormatTime, currentDateTime,, MM/dd/yy ddd
SendInput %currentDateTime%
SendInput {Space}
Send, %vInitials%:
SendInput {Space}

; MsgBox, radioGroup = %radioGroup%
}

; If the second radio button is selected
if (radioGroup = 2){

FormatTime, currentDateTime,, MM/dd/yy
SendInput %currentDateTime%
SendInput {Space}
Send, %vInitials%:
SendInput {Space}

; MsgBox, radioGroup = %radioGroup%
}

; If the third radio button is selected
if (radioGroup = 3){

FormatTime, currentDateTime,, MM/dd/yyyy
SendInput %currentDateTime%
SendInput {Space}
Send, %vInitials%:
SendInput {Space}

; MsgBox, radioGroup = %radioGroup%
}

;MsgBox, radioGroup = %radioGroup%
;MsgBox, vradioGroup = %vradioGroup%

Return