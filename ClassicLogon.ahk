; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; If the script is not elevated, relaunch as administrator and kill current instance:
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

OnExit, Exit

; write current username which is hard to get in the secure desktop to config.ini
IniWrite, %username%, config.ini, information, User

Run, %comspec% /c psexec -dsx "`%cd`%\CLSecDesktopSvc.exe",, hide
return

; write a file on ctrl+alt press to notify it to the secure desktop service
~^Alt::
IniWrite, true, config.ini, information, CtrlAltDelReady
Sleep, 2000
IniWrite, false, config.ini, information, CtrlAltDelReady
return

; kill the secure desktop service on exit
Exit:
Run, taskkill -im CLSecDesktopSvc.exe -f,, hide
ExitApp