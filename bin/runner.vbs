Set args = WScript.Arguments

if args.Count = 0 then
    WScript.Echo "Missing arguments"
    WScript.Quit 1
else
    Set oShell = CreateObject ("Wscript.Shell")
    oShell.Run args.Item(0), 0, false
end if