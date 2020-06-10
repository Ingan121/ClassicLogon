; Create GUI for the background
Gui, bg: new, +E0x08000000
Gui, bg:Color, 3A6EA5
Gui, bg:-Caption +AlwaysOnTop
Gui, bg:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Background
return

bgGuiClose:
	ExitApp