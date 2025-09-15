#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
SetWorkingDir(A_ScriptDir)

; ===== Version Information =============================================================================
compiledGitTag := "v2.1.2"

; ===== INI & Settings ==================================================================================
IniFileName := "Settings_InsertDateAndInitials.ini"

if !FileExist(IniFileName) {
    IniWrite("",             IniFileName, "Settings", "Initials")
    IniWrite("MM/dd/yy ddd", IniFileName, "Settings", "DateTimeFormat")
    IniWrite("()",           IniFileName, "Settings", "InitialsList") ; default list
}

; Active initials and format
vInitials       := IniRead(IniFileName, "Settings", "Initials",        "()")
vDateTimeFormat := IniRead(IniFileName, "Settings", "DateTimeFormat",  "MM/dd/yy ddd")

; Load list (pipe-delimited), ensure active is present
InitialsList := LoadInitialsList()
if !InitialsList.Has(vInitials)
    InitialsList.Push(vInitials), SaveInitialsList()

; ===== Tray Menu =======================================================================================
A_TrayMenu.Delete()
A_TrayMenu.Add("Show GUI", GoToShowGUI)

; Build dynamic submenu for initials
InitialsMenuLabel := "Initials"
RebuildInitialsTrayMenu()

A_TrayMenu.Add("Exit", TrayExit)
A_TrayMenu.Default := "Show GUI"

; ===== GUI Creation ====================================================================================
Main := Gui()
Main.MarginX := 10, Main.MarginY := 10
Main.SetFont("s10 cWhite", "Arial")
Main.BackColor := 0x1E1E1E
Main.Title := "Date and Initials Helper"

Main.AddText("w300 Center", "________________________________________")
Main.AddText("w300 Center", "Currently Using:")
PreviewCtrl := Main.AddText("w300 Center", "")
Main.AddText("w300 Center", "________________________________________")
Main.AddText("w300 Center", "--- General Setup / Hide to Tray ---")

btn := Main.AddButton("w300", "Change Initials"),  btn.OnEvent("Click", ChangeInitials)
btn := Main.AddButton("w300", "Edit Date Format"), btn.OnEvent("Click", EditDateTimeFormat)
btn := Main.AddButton("w300", "Hide to Tray"),     btn.OnEvent("Click", HideToTray)

Main.AddText("w300", "")
Main.AddText("w300 Center", "--- Settings / Help ---")
btn := Main.AddButton("w300", "Check for Updates"), btn.OnEvent("Click", CheckforUpdates)
btn := Main.AddButton("w300", "Reset to Default"),  btn.OnEvent("Click", ConfirmResetToDefault)
btn := Main.AddButton("w300", "Help"),              btn.OnEvent("Click", ShowHelp)
Main.AddText("w300 Right", compiledGitTag)
Main.OnEvent("Close", ConfirmExitApp)

UpdatePreview()
Main.Show()

; ===== Hotkey ==========================================================================================
Hotkey("^d", SendDateAndInitials)

SendDateAndInitials(*) {
    global vDateTimeFormat, vInitials
    dt := FormatTime(, vDateTimeFormat)  ; (Time, Format) with blank time = now
    SendText dt . " " . vInitials . ": "
}

; ===== Handlers / Functions ============================================================================

ShowHelp(*) {
    MsgBox "Usage Instructions:`n`n1) Change Initials to manage or switch saved initials.`n2) Use the hotkey Ctrl+D to insert the current date/time and active initials."
}

CheckforUpdates(*) {
    global compiledGitTag
    latestGitTag := GetLatestGithubTag("RobertCSternberg", "InsertDateandInitials")
    if (latestGitTag != "" && latestGitTag != compiledGitTag) {
        MsgBox "New version (" latestGitTag ") available! Visit https://github.com/RobertCSternberg/InsertDateandInitials/ for the latest release."
    } else if (latestGitTag = "") {
        MsgBox "Unable to fetch the latest version from GitHub."
    } else {
        MsgBox "You are using the latest version: " compiledGitTag "."
    }
}

HideToTray(*) {
    global Main
    Main.Hide()
}

ConfirmExitApp(*) {
    txt := "
    (
    Are you sure you want to quit the application?

    Instead consider hiding to the system tray. This can be done on the main menu with "Hide to Tray" and will allow you to continue using the hotkey Ctrl+D.
    )"
    if MsgBox(txt, "Quit?", "YesNo Icon?") = "Yes" {
        ExitApp()
    }
}

GoToShowGUI(*) {
    global Main
    Main.Show()
}

TrayExit(*) {
    ExitApp()
}

; ===== Change Initials (new feature) ===================================================================
ChangeInitials(*) {
    global vInitials, InitialsList

    GuiCI := Gui("-SysMenu")
    GuiCI.MarginX := 10, GuiCI.MarginY := 10
    GuiCI.SetFont("s10 cWhite", "Arial")
    GuiCI.BackColor := 0x1E1E1E
    GuiCI.Title := "Change Initials"

    GuiCI.AddText("w360", "Add a new initial, remove existing, or double-click to switch:")

    NewEdit := GuiCI.AddEdit("w180 cBlack")
    addBtn  := GuiCI.AddButton("x+m w90", "Add")
    remBtn  := GuiCI.AddButton("x+m w120", "Remove Selected")
    useBtn  := GuiCI.AddButton("w120", "Use Selected")
    closeBtn:= GuiCI.AddButton("x+m w90", "Close"), closeBtn.OnEvent("Click", (*) => GuiCI.Destroy())

    LV := GuiCI.AddListView("w360 r10 Grid", ["Initials"])
    LV.SetFont("cBlack")
    LV.ModifyCol(1, 320)

    FillInitialsLV(LV)

    LV.OnEvent("DoubleClick", (*) => (
        (init := GetLVSelected(LV)) ? (SetActiveInitials(init), GuiCI.Destroy()) : 0
    ))

    addBtn.OnEvent("Click", (*) => (
        val := Trim(NewEdit.Value)
      , val := StrUpper(val)
      , (val != "")
        ? (AddInitials(val), NewEdit.Value := "", FillInitialsLV(LV))
        : 0
    ))

    remBtn.OnEvent("Click", (*) => (
        (init := GetLVSelected(LV))
        ? (RemoveInitials(init), FillInitialsLV(LV))
        : MsgBox("Select an initial to remove.", "No selection", "Icon!")
    ))

    useBtn.OnEvent("Click", (*) => (
        (init := GetLVSelected(LV))
        ? (SetActiveInitials(init), GuiCI.Destroy())
        : MsgBox("Select an initial to use.", "No selection", "Icon!")
    ))

    GuiCI.Show()
}

GetLVSelected(lv) {
    row := lv.GetNext()
    return row ? lv.GetText(row, 1) : ""
}

FillInitialsLV(lv) {
    lvCount := lv.GetCount()
    while (lv.GetCount() > 0)
        lv.Delete(1)
    global InitialsList, vInitials
    for _, init in InitialsList {
        idx := lv.Add("", init)
        if (init = vInitials)
            lv.Modify(idx, "Select Focus")
    }
}

AddInitials(init) {
    global InitialsList
    ; avoid duplicates
    for _, v in InitialsList
        if (v = init)
            return
    InitialsList.Push(init)
    SaveInitialsList()
    RebuildInitialsTrayMenu()
}

RemoveInitials(init) {
    global InitialsList, vInitials
    idx := 0
    for i, v in InitialsList
        if (v = init) {
            idx := i
            break
        }
    if (idx) {
        InitialsList.RemoveAt(idx)
        ; if we removed the active one, switch to first if any, else "()"
        if (init = vInitials) {
            newActive := InitialsList.Length ? InitialsList[1] : "()"
            SetActiveInitials(newActive, false) ; false => don't rebuild list again (we will below)
        } else {
            SaveInitialsList()
        }
        RebuildInitialsTrayMenu()
    }
}

SetActiveInitials(newInit, rebuild := true) {
    global vInitials, IniFileName
    vInitials := newInit
    IniWrite(vInitials, IniFileName, "Settings", "Initials")      ; keep legacy key for compatibility
    UpdatePreview()
    if rebuild
        RebuildInitialsTrayMenu()
}

LoadInitialsList() {
    global IniFileName
    raw := IniRead(IniFileName, "Settings", "InitialsList", "")
    list := []
    if (raw != "") {
        for _, seg in StrSplit(raw, "|") {
            seg := Trim(seg)
            if (seg != "")
                list.Push(seg)
        }
    } else {
        ; fall back to single active initial if list missing
        act := IniRead(IniFileName, "Settings", "Initials", "()")
        list := [act]
        IniWrite(act, IniFileName, "Settings", "InitialsList")
    }
    ; provide handy .Has() for membership checks
    list.DefineProp("Has", {Call:(this, x) => (IndexOf(this, x) != 0)})
    return list
}

IndexOf(arr, val) {
    for i, v in arr
        if (v = val)
            return i
    return 0
}

SaveInitialsList() {
    global IniFileName, InitialsList, vInitials
    ; ensure active is present
    pres := false
    for _, v in InitialsList {
        if (v = vInitials) {
            pres := true
            break
        }
    }
    if !pres
        InitialsList.Push(vInitials)

    IniWrite(StrJoin(InitialsList, "|"), IniFileName, "Settings", "InitialsList")
}

StrJoin(arr, delim := ",") {
    out := ""
    for i, v in arr
        out .= (i>1 ? delim : "") . v
    return out
}

RebuildInitialsTrayMenu() {
    global InitialsMenuLabel, InitialsList, A_TrayMenu
    ; remove old submenu if it exists
    try A_TrayMenu.Delete(InitialsMenuLabel)
    catch as err {
        ; ignore if not present yet
    }

    sub := Menu()
    ; each initials entry points to one common handler
    for _, init in InitialsList
        sub.Add(init, SwitchInitialsFromTray)

    sub.Add("Change Initials...", ChangeInitials)
    A_TrayMenu.Add(InitialsMenuLabel, sub)
}

; Menu callback: first param is the clicked item's label (the initials)
SwitchInitialsFromTray(ItemName, ItemPos := "", MyMenu := "") {
    if ItemName
        SetActiveInitials(ItemName)
}

; ===== Date Format Picker (ListView tabs with examples) ===============================================
EditDateTimeFormat(*) {
    global vDateTimeFormat, IniFileName

    FormatPicker := Gui("-SysMenu")
    FormatPicker.MarginX := 10, FormatPicker.MarginY := 10
    FormatPicker.SetFont("s10 cWhite", "Consolas")  ; white for labels; LV sets its own color
    FormatPicker.BackColor := 0x1E1E1E
    FormatPicker.Title := "Update Date Format"

    FormatPicker.AddText("w360", "Example Date (for preview below):  January 2, 2003 (Thu)")

    useBtn    := FormatPicker.AddButton("w120", "Use Selected")
    cancelBtn := FormatPicker.AddButton("x+m w120", "Cancel")
    cancelBtn.OnEvent("Click", (*) => FormatPicker.Destroy())

    tab := FormatPicker.AddTab("vMyTab", ["No Weekday","Weekday Short","Weekday Long","Month Written","Full Dates"])
    sampleDate := "20030102090000" ; Thu, Jan 2, 2003 @ 09:00

    tabLVs := []  ; listviews per tab

    tab.UseTab(1)
    tabLVs.Push( MakeLV(FormatPicker, sampleDate, ["MM/yy","MM/dd","MM/yyyy","MM/dd/yy","MM/dd/yyyy","yyyy/MM/dd"]) )

    tab.UseTab(2)
    tabLVs.Push( MakeLV(FormatPicker, sampleDate, ["MM/dd ddd","MM/dd/yy ddd","MM/dd/yyyy ddd"]) )

    tab.UseTab(3)
    tabLVs.Push( MakeLV(FormatPicker, sampleDate, ["MM/dd dddd","MM/dd/yy dddd","MM/dd/yyyy dddd"]) )

    tab.UseTab(4)
    tabLVs.Push( MakeLV(FormatPicker, sampleDate, ["MMM dd.","MMM dd","MMMM dd","MMMM dd, yyyy"]) )

    tab.UseTab(5)
    tabLVs.Push( MakeLV(FormatPicker, sampleDate, ["dddd, MMMM dd, yyyy"]) )

    tab.UseTab()

    apply := (fmt) => (
        vDateTimeFormat := fmt
      , IniWrite(vDateTimeFormat, IniFileName, "Settings", "DateTimeFormat")
      , UpdatePreview()
      , FormatPicker.Destroy()
    )

    GetSelectedFmt := () => (
        idx := tab.Value
      , lv := tabLVs[idx]
      , row := lv.GetNext()
      , (row ? lv.GetText(row, 2) : "")
    )

    for _, lv in tabLVs
        lv.OnEvent("DoubleClick", (*) => (
            (fmt := GetSelectedFmt()) ? apply(fmt) : 0
        ))

    useBtn.OnEvent("Click", (*) => (
        (fmt := GetSelectedFmt()) ? apply(fmt) : MsgBox("Please select a format first.", "No selection", "Icon!")
    ))

    FormatPicker.Show()
}

; helper to create & fill a LV with examples (black text on white)
MakeLV(containerGui, sampleDate, fmts) {
    lv := containerGui.AddListView("w360 r10 Grid", ["Example","Format"])
    lv.SetFont("cBlack")
    lv.ModifyCol(1, 220), lv.ModifyCol(2, 120)
    for _, fmt in fmts {
        ex := FormatTime(sampleDate, fmt)   ; (Time, Format)
        lv.Add("", ex, fmt)
    }
    return lv
}

; ===== Reset & Preview =================================================================================
ConfirmResetToDefault(*) {
    if MsgBox("Are you sure you want to reset the settings to default? This action cannot be undone.", "Reset to Default", "YesNo Icon!") = "Yes" {
        ResettoDefault()
    }
}

ResettoDefault() {
    global vDateTimeFormat, vInitials, IniFileName, InitialsList
    vDateTimeFormat := "MM/dd/yy ddd"
    IniWrite(vDateTimeFormat, IniFileName, "Settings", "DateTimeFormat")

    ; reset initials to default "()"
    vInitials := "()"
    InitialsList := ["()"]
    SaveInitialsList()
    IniWrite(vInitials, IniFileName, "Settings", "Initials")
    RebuildInitialsTrayMenu()
    UpdatePreview()
}

UpdatePreview() {
    global PreviewCtrl, vDateTimeFormat, vInitials
    dt := FormatTime(, vDateTimeFormat)  ; (Time, Format)
    PreviewCtrl.Text := dt . " " . vInitials . ": "
}

; ===== GitHub Tag Helper ==============================================================================
GetLatestGithubTag(username, repo) {
    try {
        url := "https://api.github.com/repos/" username "/" repo "/releases/latest"
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, false)
        whr.SetRequestHeader("User-Agent", "AHK Script")
        whr.Send()
        if whr.Status != 200
            return ""
        response := whr.ResponseText
        tagPattern := '"tag_name":\s*"(v?\d+\.\d+\.\d+)"'
        if RegExMatch(response, tagPattern, &m)
            return m[1]
        return ""
    } catch {
        return ""
    }
}
