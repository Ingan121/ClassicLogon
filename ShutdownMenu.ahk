#SingleInstance ignore
#NoTrayIcon
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

arg1 = %1%
; Create GUI for the background
Gui, bg:-Caption +AlwaysOnTop +ToolWindow
Gui, bg:Color, black
if (arg1 != "nobg") {
	Gui, bg:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Background
	WinSet, Trans, 170, Background
}

; Create Main UI
IniRead, logo, config.ini, config, Logo
Gui, new, -SysMenu +Ownerbg
Gui, Add, Picture, x70 y0 w400 h70, %logo%
Gui, Add, Picture, x0 y70 w540 h5, 2kBar.bmp
Gui, Add, Picture, x22 y85 w32 h32, 2kLockIcon.ico
Gui, Add, Text, x78 y83 w367 h20, 원하는 작업을 선택하세요(&W).
Gui, Add, DropDownList, x78 y111 w380 vDDL gDDL AltSubmit, 사용자 전환|로그아웃|절전|최대 절전 모드|시스템 종료|다시 시작
Gui, Add, Text, x78 y151 w380 h60 vText, 앱을 모두 닫고 PC를 종료합니다.
Gui, Add, Button, x249 y211 w90 h28 Default, 확인
Gui, Add, Button, x346 y211 w90 h28, 취소
Gui, Add, Button, x443 y211 w90 h28 gHelp, 도움말(&H)
GuiControl, Choose, DDL, 시스템 종료
; Generated using SmartGuiXP Creator mod 4.3.29.7
Gui, Show, y230 w546 h255, Windows 종료

/*
  ShellRun by Lexikos
    requires: AutoHotkey v1.1
    license: http://creativecommons.org/publicdomain/zero/1.0/

  Credit for explaining this method goes to BrandonLive:
  http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/
 
  Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
  http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
; This is for preventing Firefox from running in secure desktop.
ShellRun(prms*)
{
    shellWindows := ComObjCreate("Shell.Application").Windows
    VarSetCapacity(_hwnd, 4, 0)
    desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)
   
    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetCapacity(IID_IDispatch, 16)
            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")
           
            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)
           
            ; Get Shell object.
            shell := ComObj(9,pdisp,1).Application
           
            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)
           
            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}

; Try to return to normal desktop if it seems to be in secure desktop (checked by explorer.exe presense)
ReturnToDesktop() {
    if (!WinExist("ahk_exe explorer.exe")) {
        Send ^+{Esc}
    }
}

; Prevent being unfocused by clicking its background
While (true) {
	WinWaitActive Background ahk_exe ShutdownMenu.exe
	WinActivate Windows 종료 ahk_exe ShutdownMenu.exe
}
Return

DDL:
; Change task descriptions
Gui, Submit, NoHide
if (DDL = 1) {
	GuiControl, Text, Text, 앱을 닫지 않고 사용자를 전환합니다.
} else if (DDL = 2) {
	GuiControl, Text, Text, 모든 앱을 종료하고 로그아웃합니다.
} else if (DDL = 3) {
	GuiControl, Text, Text, PC가 켜져 있지만 저 전원 상태입니다. 앱은 열려 있으므로 PC의 절전 모드를 해제하면 즉시 이전 상태로 돌아갑니다.
} else if (DDL = 4) {
	GuiControl, Text, Text, PC를 끄지만 앱은 열어 둡니다. PC를 켜면 이전 상태로 돌아갑니다.
} else if (DDL = 5) {
	GuiControl, Text, Text, 앱을 모두 닫고 PC를 종료합니다.
} else if (DDL = 6) {
	GuiControl, Text, Text, 앱을 모두 닫고 PC를 다시 시작합니다.
}
return

Button확인:
; Perform selected task
Gui, Submit
if (DDL = 1) {
	RunWait, tsdiscon,, Hide
    ReturnToDesktop()
} else if (DDL = 2) {
	RunWait, ShutdownHelper.bat logoff,, Hide
} else if (DDL = 3) {
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
    ReturnToDesktop()
} else if (DDL = 4) {
	RunWait, shutdown /h,, Hide
    ReturnToDesktop()
} else if (DDL = 5) {
	RunWait, ShutdownHelper.bat shutdown,, Hide
} else if (DDL = 6) {
	RunWait, ShutdownHelper.bat reboot,, Hide
}
ExitApp

Help:
; Open the MS help page with Firefox as limited privileges to prevent it from running in the secure desktop.
ShellRun("C:\Program Files\Mozilla Firefox\firefox.exe", "https://go.microsoft.com/fwlink/?LinkId=517009")
ReturnToDesktop()
; Exit
Button취소:
GuiEscape:
GuiClose:
bgGuiEscape:
bgGuiClose:
ExitApp