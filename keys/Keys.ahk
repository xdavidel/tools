#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force

#p::
Run, c:\tools\bin\runner.vbs "mediactrl t"
return

#.::
Run, c:\tools\bin\runner.vbs "mediactrl n"
return

#,::
Run, c:\tools\bin\runner.vbs "mediactrl p"
return

#[::
Run, c:\tools\bin\runner.vbs "mediactrl b"
return

#]::
Run, c:\tools\bin\runner.vbs "mediactrl f"
return

#=::
Send, {Volume_Up}
return

#-::
Send, {Volume_Down}
return

#+m::
Send, {Volume_Mute}
return

#m::
Run, cmd /C ncmpc.lnk
return

#a::
Run, cmd /C python
return

; WINDOWS KEY + H TOGGLES HIDDEN FILES
#h::
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
If HiddenFiles_Status = 2 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
Else 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2

;refresh Desktop/folder windows
DetectHiddenWindows, On
GroupAdd, vGroupFolder, ahk_class CabinetWClass
GroupAdd, vGroupFolder, ahk_class ExploreWClass
PostMessage, 0x111, 28931, , SHELLDLL_DefView1, ahk_class Progman
WinGet, vWinList, List, ahk_group vGroupFolder
Loop, %vWinList%
PostMessage, 0x111, 41504, , ShellTabWindowClass1, % "ahk_id " vWinList%A_Index%
;PostMessage, 0x111, 28931, , SHELLDLL_DefView1, % "ahk_id " vWinList%A_Index% ;also works
Return

#Enter::
Run, cmd /K cd /
return

#+Enter::
Run, wsl.exe
return

#d::
Run, c:\tools\bin\runner.vbs "dmenu_run.bat"
return

#q::
WinClose, A
return

#+q::
WinKill, A
return

#F8::
Run,  c:\tools\bin\runner.vbs vboxes
return

#F9::
Run,  c:\tools\bin\runner.vbs "powershell mounter.ps1"
return

^!r::Reload
return

; Globals
DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
 global CurrentDesktop, DesktopCount
 ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
 IdLength := 32
 SessionId := getSessionId()
 if (SessionId) {
 RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
 if (CurrentDesktopId) {
 IdLength := StrLen(CurrentDesktopId)
 }
 }
 ; Get a list of the UUIDs for all virtual desktops on the system
 RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
 if (DesktopList) {
 DesktopListLength := StrLen(DesktopList)
 ; Figure out how many virtual desktops there are
 DesktopCount := DesktopListLength / IdLength
 }
 else {
 DesktopCount := 1
 }
 ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
 i := 0
 while (CurrentDesktopId and i < DesktopCount) {
 StartPos := (i * IdLength) + 1
 DesktopIter := SubStr(DesktopList, StartPos, IdLength)
 OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
 ; Break out if we find a match in the list. If we didn't find anything, keep the
 ; old guess and pray we're still correct :-D.
 if (DesktopIter = CurrentDesktopId) {
 CurrentDesktop := i + 1
 OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
 break
 }
 i++
 }
}
;
; This functions finds out ID of current session.
;
getSessionId()
{
 ProcessId := DllCall("GetCurrentProcessId", "UInt")
 if ErrorLevel {
 OutputDebug, Error getting current process id: %ErrorLevel%
 return
 }
 OutputDebug, Current Process Id: %ProcessId%
 DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
 if ErrorLevel {
 OutputDebug, Error getting session id: %ErrorLevel%
 return
 }
 OutputDebug, Current Session Id: %SessionId%
 return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop)
{
 global CurrentDesktop, DesktopCount
 ; Re-generate the list of desktops and where we fit in that. We do this because
 ; the user may have switched desktops via some other means than the script.
 mapDesktopsFromRegistry()
 ; Don't attempt to switch to an invalid desktop
 if (targetDesktop > DesktopCount || targetDesktop < 1) {
 OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
 return
 }
 ; Go right until we reach the desktop we want
 while(CurrentDesktop < targetDesktop) {
 Send ^#{Right}
 CurrentDesktop++
 OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
 }
 ; Go left until we reach the desktop we want
 while(CurrentDesktop > targetDesktop) {
 Send ^#{Left}
 CurrentDesktop--
 OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
 }
}
;
; This function switches to the desktop number provided.
;
moveToDesktopNumber(targetDesktop)
{
 global CurrentDesktop, DesktopCount, MoveWindowToDesktopNumberProc
 ; Re-generate the list of desktops and where we fit in that. We do this because
 ; the user may have switched desktops via some other means than the script.
 mapDesktopsFromRegistry()
 ; Don't attempt to switch to an invalid desktop
 if (targetDesktop > DesktopCount || targetDesktop < 1) {
 OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
 return
 }
 WinGet, activeHwnd, ID, A

 hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", "c:\tools\keys\VirtualDesktopAccessor.dll", "Ptr")
 MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
 DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, targetDesktop -1)
 DllCall("FreeLibrary", "Ptr", hVirtualDesktopAccessor)
}
;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^d
 DesktopCount++
 CurrentDesktop = %DesktopCount%
 OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^{F4}
 DesktopCount--
 CurrentDesktop--
 OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
; User config!
; This section binds the key combo to the switch/create/delete actions
#1::switchDesktopByNumber(1)
#2::switchDesktopByNumber(2)
#3::switchDesktopByNumber(3)
#4::switchDesktopByNumber(4)
#5::switchDesktopByNumber(5)
#6::switchDesktopByNumber(6)
#7::switchDesktopByNumber(7)
#8::switchDesktopByNumber(8)
#9::switchDesktopByNumber(9)

#+1::moveToDesktopNumber(1)
#+2::moveToDesktopNumber(2)
#+3::moveToDesktopNumber(3)
#+4::moveToDesktopNumber(4)
#+5::moveToDesktopNumber(5)
#+6::moveToDesktopNumber(6)
#+7::moveToDesktopNumber(7)
#+8::moveToDesktopNumber(8)
#+9::moveToDesktopNumber(9)

^2::moveToDesktopNumber(2)
; #+1::moveToDesktopNumber(1)
; #+2::moveToDesktopNumber(2)


^!c::createVirtualDesktop()
^!d::deleteVirtualDesktop()