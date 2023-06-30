# Insert Date and Initials

## This script helps the user instantly insert the current date (in their preferred format) and their initials wherever they are typing, by simply pressing Ctrl + d. This can be useful in various scenarios such as signing emails, writing documents, etc., where the user frequently needs to insert the current date and their initials.

### Initialization and Configurations: 
The initial part of the script sets several configurations to ensure reliable and predictable behavior. For example, SendMode Input sets the send command to use the Input mode, which is faster and more reliable. The working directory is set to the directory of the script file.

### Date Formatting: 
The script formats the current date into three different styles (MM/dd/yy ddd, MM/dd/yy, MM/dd/yyyy) and stores the formatted strings in three variables.

### GUI Creation: 
The script creates a graphical user interface (GUI) that includes text instructions, an input field for initials, and three radio buttons for selecting the desired date format.

### Radio Buttons and Input Fields: 
The user can input their initials in the GUI and choose the desired date format by selecting one of the radio buttons.

### Hotkey Definition: 
A hotkey (Ctrl + d) is defined. When the user presses the hotkey, the script will check which radio button is selected (i.e., which date format the user has chosen). It will then re-format the current date and time according to the user's selection, and send the formatted date and time, followed by the user's initials.
