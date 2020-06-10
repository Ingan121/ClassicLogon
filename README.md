# ClassicLogon
 Windows 2000-like lock and security screen for Windows 10

* Requires PsExec from PsTools to be installed in %PATH%
* Currently only Korean language support
* To get all features working, compile all AHKs and run compiled EXEs, instead of running AHKs directly
* This works really messy so using it is not that recommended. I hope this to be converted to non-AHK langage and switched to Windows service-based method for showing custom logon screen.

## config.ini
* The [information] section is used for the interaction between main and secure desktop service, so there is no need to edit it manually.
* Logo: Filename (relative path) of OS logo
* NoBG: Do not show background
* SmallBG: Make background small (ignored if NoBG)
* Debug: Show the debug window by default (always shown if manually started in normal desktop)
* ShowDebugOnCtrlD: Show the debug window on Ctrl+D