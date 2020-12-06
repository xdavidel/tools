@echo off

:: Copy shortcuts to startup
del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\keys.lnk"
mklink "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\keys.lnk" "C:\tools\keys\Keys.ahk" 

:: Set bin directory in path
setx /M PATH "%path%;C:\tools\bin"