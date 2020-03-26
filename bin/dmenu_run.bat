for /F "tokens=*" %%i in ('apps ^| dmenu -i -p "Run"') do set app=%%i
IF ["%p%"] == "" (
	exit  
)

start "" "%app%"
