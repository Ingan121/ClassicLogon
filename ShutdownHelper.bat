@echo off
if "%1" == "" echo Usage: ShutdownHelper [shutdown ^| reboot ^| logoff^] [showbg]
if "%2" == "showbg" start ShutdownBG
powershell -c (New-Object Media.SoundPlayer 'C:\Windows\Media\2kLogoff.wav').PlaySync();
if "%1" == "shutdown" shutdown /s /t 0
if "%1" == "reboot" shutdown /r /t 0
if "%1" == "logoff" logoff