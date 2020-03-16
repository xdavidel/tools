@echo off
xcopy /y "C:\tools\startup\*" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"
SET pattern="c:\tools\bin"


for /F "tokens=*" %%i in ('set ^| findstr /I "%pattern%"') do set p=%%i
IF ["%p%"] == [] (
  setx /M path "%path%;%pattern%"
)