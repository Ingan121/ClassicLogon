#SingleInstance Force
#Persistent

SetWorkingDir %A_ScriptDir%

cb:=RegisterCallback("HookProc", "F")
hWinEventHook:=DllCall("SetWinEventHook",UInt,0x20,Uint,0x20,UInt,0,UInt,cb,Uint,0,Uint,0,Uint,0)
OnExit, Exit

IniRead, user, config.ini, information, User
Run, %comspec% /c GetLastLogonTime.cmd > lastlogontime.txt,, hide
sleep 1000
FileRead, lastlogon, lastlogontime.txt
ConsoleLogonEnabled := !FileExist("C:\WINDOWS\system32\Windows.UI.Logon.dll")

; Create GUI for the background
Gui, bg: new, +E0x08000000
Gui, bg:Color, 3A6EA5
Gui, bg:-Caption +AlwaysOnTop
IniRead, nobg, config.ini, config, NoBG
if (%nobg% != true) {
	IniRead, smallbg, config.ini, config, SmallBG
	if (%smallbg% == true) {
		Gui, bg:Show, w600 h400 Center, Background
	} else {
		Gui, bg:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Background
	}
}

; Show a debug window if debug mode is enabled in config.ini or running in normal desktop
Gui, debug:new, +AlwaysOnTop -Border +Caption -Disabled -LastFound -MinimizeBox -MaximizeBox -OwnDialogs -Resize +SysMenu -Theme -ToolWindow +Ownerbg
Gui, debug:Add, Text,, Classic Logon by Ingan121
Gui, debug:Add, Text,, %computername%\%user%
Gui, debug:Add, Text,, Last Logon: %lastlogon%
Gui, debug:Add, Text, vStatus, Status: Undetected
Gui, debug:Add, Button, gShowLockWindow, Show lock window
Gui, debug:Add, Button, gShowSecurityWindow, Show Ctrl+Alt+Delete window
Gui, debug:Add, Button, gHideWindows, Hide both windows
Gui, debug:Add, Button, gShowBG, Show background
Gui, debug:Add, Button, gHideBG, Hide background
Gui, debug:Add, Button, gReload, Reload
Gui, debug:Add, Button, gExit, Exit
IniRead, debug, config.ini, config, Debug
if(%debug% == true or WinExist("ahk_exe explorer.exe")) {
	Gui, debug:Show, x0 y0, Debug Window
}

; Create GUI for the Ctrl+Alt+Del menu
Gui, sec:new, +AlwaysOnTop -Border +Caption -Disabled -LastFound -MinimizeBox -MaximizeBox -OwnDialogs -Resize -SysMenu -Theme -ToolWindow +Ownerbg
Gui, sec:Add, Button, Default x11 y190 w147 h24 vLock gLock, 컴퓨터 잠금(&K)
Gui, sec:Add, Button, x165 y190 w147 h24 gLogoff, 로그오프(&L)...
Gui, sec:Add, Button, x319 y190 w147 h24 gShutdown, 시스템 종료(&S)...
Gui, sec:Add, Button, x11 y219 w147 h24 gPasswd, 암호 변경(&P)...
Gui, sec:Add, Button, x165 y219 w147 h24 gTaskmgr, 작업 관리자(&T)
Gui, sec:Add, Button, x319 y219 w147 h24 gCancel, 취소
Gui, sec:Add, Text, x11 y171 w466 h14 , 응답하지 않는 응용 프로그램을 닫으려면 [작업 관리자]를 사용하십시오.
Gui, sec:Add, GroupBox, x11 y82 w455 h78 , 로그온 정보
Gui, sec:Add, Text, x25 y103 w431 h27 , 사용자가 %computername%\%user%(으)로 로그온했습니다.
Gui, sec:Add, Text, x25 y136 w88 h14 , 로그온 날짜:
Gui, sec:Add, Text, x122 y136 w333 h14 , %lastlogon%
IniRead, logo, config.ini, config, Logo
Gui, sec:Add, Picture, x0 y0 w400 h70, %logo%
Gui, sec:Add, Picture, x0 y70 w480 h5, 2kBar.bmp

; Create GUI for the lock screen
Gui, lock:new, +AlwaysOnTop -Border +Caption -Disabled -LastFound -MinimizeBox -MaximizeBox -OwnDialogs -Resize -SysMenu -Theme -ToolWindow +Ownerbg
Gui, lock:Add, Text, x83 y85 w383 h14, 이 컴퓨터는 사용 중이며 잠겨 있습니다.
Gui, lock:Add, Text, x83 y103 w383 h33, %computername%\%user% 또는 관리자만이 이 컴퓨터의 잠금을 해제할 수 있습니다.
Gui, lock:Add, Text, x83 y144 w96 h14, 사용자 이름(&U):
Gui, lock:Add, Edit, x195 y141 w221 h17 vUsername, %user%
Gui, lock:Add, Text, x83 y166 w70 h14, 암호(&P):
Gui, lock:Add, Edit, Password x195 y163 w221 h17 vPwInput, 
Gui, lock:Add, Button, Default x289 y191 w88 h24 vUnlock gUnlock, 확인
Gui, lock:Add, Button, x384 y191 w88 h24 gLockSwitchUser, 취소
Gui, lock:Add, Picture, x22 y85 w32 h32, 2kLockIcon.ico
Gui, lock:Add, Picture, x0 y0 w400 h70, %logo%
Gui, lock:Add, Picture, x0 y70 w480 h5, 2kBar.bmp
Gui, lock:Show, Center w478 h223, 컴퓨터 잠금 해제
GuiControl, Focus, lock:PwInput
Return

Lock:
	ActivateLogonUI()
	Send {Enter}
	ShowLockWindow()
	GuiControl, debug:, Status, Status: Locked
	Gui, sec:Hide
	return

Logoff:
	ActivateLogonUI()
	if(ConsoleLogonEnabled) {
		Send {Down}{Enter}
	} else {
		Send {Down}{Down}{Enter}
	}
	CloseSecurityMenu()
	return

SecuritySwitchUser:
	Run, tsdiscon,, Hide
	CloseSecurityMenu()
	return

Passwd:
	MsgBox 0x40000, 암호 변경, 암호를 변경하려면 설정→계정→로그인 옵션으로 이동하십시오.
	return

Shutdown:
	Gui, sec:Hide
	RunWait, ShutdownMenu.exe nobg
	Gui, sec:Show
	return

Taskmgr:
	ActivateLogonUI()
	Send {Down}{Down}{Down}{Enter}
	CloseSecurityMenu()
	return

LockSwitchUser:
	Run, tsdiscon,, Hide
	ShowLockWindow()
	return

secGuiEscape:
Cancel:
	Send ^+{Esc}
	CloseSecurityMenu()
	return

Unlock:
	GuiControlGet, Username,, Username
	if (%Username% != %user%) {
		MsgBox, 262160, 오류, 이 컴퓨터는 잠겨 있습니다. 로그온한 사용자만이 잠금을 해제할 수 있습니다. 다른 사용자로 로그온하려면 취소 버튼을 누르십시오.
	} else {
		GuiControlGet, PwInput,, PwInput
		PwInput := StrReplace(PwInput, "!", "{!}")
		ActivateLogonUI()
		if(PwErrorOnce) {
			if(ConsoleLogonEnabled) {
				Send {Tab}
			}
			Send %PwInput%{Enter}
			PwErrorOnce := false
		} else {
			Send %Username%{Tab}%PwInput%{Enter}
		}
		Sleep 700
		GuiControl, lock:, PwInput,
		Process, Exist, LogonUI.exe
		if (!ErrorLevel = 0) {
			MsgBox, 262160, 오류, 사용자 이름 또는 암호가 올바르지 않습니다. (오작동시 Alt+F4)
			ActivateLogonUI()
			Send {Enter}
			ShowLockWindow()
			PwErrorOnce := true
		}
	}
	return
	
ShowLockWindow:
	ShowLockWindow()
	return
	
ShowSecurityWindow:
	Gui, sec:Show, Center h256 w480, Windows 보안
	GuiControl, sec:Focus, Lock
	return
	
HideWindows:
	Gui, lock:Hide
	Gui, sec:Hide
	return
	
ShowBG:
	IniRead, smallbg, config.ini, config, SmallBG
	if (%smallbg% == true) {
		Gui, bg:Show, w600 h400 Center, Background
	} else {
		Gui, bg:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Background
	}
	return
	
HideBG:
	Gui, bg:Hide
	return
	
Reload:
	reload
	return
	
debugGuiEscape:
	Gui, debug:Hide
	return

~^D::
	IniRead, showDebugOnCtrlD, config.ini, config, ShowDebugOnCtrlD
	if (%showDebugOnCtrlD% == true) {
		Gui, debug:Show, x0 y0, Debug Window
	}
	return

ShowLockWindow() {
	Gui, lock:Show, Center w478 h223, 컴퓨터 잠금 해제
	GuiControl, lock:Focus, Unlock
	GuiControl, lock:Focus, PwInput
}

ActivateLogonUI() {
	WinActivate ahk_exe LogonUI.exe
	WinWaitActive ahk_exe LogonUI.exe
}

CloseSecurityMenu() {
	Sleep 100
	Gui, sec:Hide
	ShowLockWindow()
}

HookProc() {
	IniRead, CtrlAltDelReady, config.ini, information, CtrlAltDelReady
	if (%CtrlAltDelReady% == true) {
		Gui, lock:Hide
		GuiControl, debug:, Status, Status: Security
		Gui, sec:Show, Center h256 w480, Windows 보안
		GuiControl, sec:Focus, Lock
	} else {
		Process, Exist, consent.exe
		if (!ErrorLevel = 0) {
			Gui, lock:Hide
			Gui, bg:Hide
			GuiControl, debug:, Status, Status: UAC
			sleep, 100
			WinWaitClose, ahk_exe consent.exe
			Gui, bg:Show
			ShowLockWindow()
		} else {
			ShowLockWindow()
			sleep 200
			Process, Exist, LogonUI.exe
			if (!ErrorLevel = 0) {
				GuiControl, debug:, Status, Status: Locked
			} else {
				GuiControl, debug:, Status, Status: Undetected
			}
		}
	}
}

secGuiClose:
lockGuiClose:
bgGuiClose:
Exit:
DllCall("UnhookWinEvent", Uint, hWinEventHook)
if not (A_ExitReason <> Reload) {
	Run, taskkill -im ClassicLogon.exe -f,, hide
}
ExitApp