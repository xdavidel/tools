((Get-ChildItem Env:PATHEXT).Value).Split(';') | ForEach-Object {
    (Get-Command *$_).Name
} | dmenu -i | Invoke-Expression