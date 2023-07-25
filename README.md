# Insert Date and Initials

#### This script helps the user instantly insert the current date (in their preferred format) and their initials wherever they are typing, by simply pressing Ctrl + d. This can be useful in various scenarios such as signing emails, writing documents, etc., where the user frequently needs to insert the current date and their initials.

### Initialization and Configurations: 
The initial part of the script sets several configurations to ensure reliable and predictable behavior. For example, SendMode Input sets the send command to use the Input mode, which is faster and more reliable. The working directory is set to the directory of the script file.  The script will create a .ini file in the same directory as the .exe or .ahk file.  It will be used to store settings for use in the script. 

### Initials Formatting: 
The script forces uppercase initials surrounded by square brackets, this can be overridden by manually modifing the .ini file. 

### Date Formatting: 
The script formats the current date into a default style of MM/dd/yy ddd and can be modified by the end user. 

### GUI Creation: 
The script creates a graphical user interface (GUI) that includes a help function, a collapse to tray function, an input function for initials, and an input function to update DateTime formatting. 

### Hotkey Definition: 
A hotkey (Ctrl + d) is defined. When the user presses the hotkey, the script will check which radio button is selected (i.e., which date format the user has chosen). It will then re-format the current date and time according to the user's selection, and send the formatted date and time, followed by the user's initials.
