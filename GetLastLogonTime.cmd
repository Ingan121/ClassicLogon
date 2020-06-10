@echo off
setlocal ENABLEDELAYEDEXPANSION
for /f "skip=1 tokens=* USEBACKQ" %%G IN (`quser`) DO if not defined line set "line=%%G"
set line=%line:>=!""!%
set t=%line%
for /f "tokens=6" %%G in ("%t%") do set result=%%G
for /f "tokens=7" %%G in ("%t%") do set result=%result% %%G
for /f "tokens=8" %%G in ("%t%") do set result=%result% %%G
for /f "tokens=9" %%G in ("%t%") do set result=%result% %%G
echo %result%