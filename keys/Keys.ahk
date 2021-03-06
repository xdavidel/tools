﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
setTitleMatchMode, 2 ; set title match mode to "contains"

; Available eys
; ---------------
; # = Superkey
; ^ = Ctrl
; ! = Alt
; + = Shift

#SingleInstance force

; move active window 100 pixels right
#!l::
wingetpos x,y,w,h,A          ; get coordinates of the active window
x += 100			         ; add 100 to the x coordinate
winmove, A,,%x%,%y%,%w%,%h%  ; make the active window use the new coordinates
return				         ; finish

; move active window 100 pixels left
#!h::
wingetpos x,y,w,h,A
x -= 100
winmove, A,,%x%,%y%,%w%,%h%
return

; move active window 100 pixels up
#!k::
wingetpos x,y,w,h,A
y -= 100
winmove, A,,%x%,%y%,%w%,%h%
return

; move active window 100 pixels down
#!j::
wingetpos x,y,w,h,A
y += 100
winmove, A,,%x%,%y%,%w%,%h%
return


; resize active window +50 pixels right
#!right::
wingetpos x,y,w,h,A
w += 50
winmove, A,,%x%,%y%,%w%,%h%
return

; resize active window -50 pixels right
#!left::
wingetpos x,y,w,h,A
w -= 50
winmove, A,,%x%,%y%,%w%,%h%
return

; resize active window +50 pixels down
#!down::
wingetpos x,y,w,h,A
h += 50
winmove, A,,%x%,%y%,%w%,%h%
return

; resize active window -50 pixels down
#!up::
wingetpos x,y,w,h,A
h -= 50
winmove, A,,%x%,%y%,%w%,%h%
return

; Toggle music play/pause
#p::
Run, cmd /c "mediactrl t",,Hide
return

; Next song
#.::
Run, cmd /c "mediactrl n",,Hide
return

; Previus song 
#,::
Run, cmd /c "mediactrl p",,Hide
return

; Backward song
#[::
Run, cmd /c "mediactrl b",,Hide
return

; Forward song
#]::
Run, cmd /c "mediactrl f",,Hide
return

; Volume Up
#=::
Send, {Volume_Up}
return

; Volume Down
#-::
Send, {Volume_Down}
return

; Volume Mute
#+m::
Send, {Volume_Mute}
return

; Audio Media Player
#m::
If !ProcessExist("mpd.exe")
	Run, mpd,,Hide
Run, cmd /C "ncmpc.lnk"
return

; Python shell
#a::
Run, cmd /C python
return

; Web Browser
#w::
ActivateOrOpen("- Brave", "brave.exe")
return

; Window Transparentcy
#+End::
WinGet, currentTransparency, Transparent, A
if (currentTransparency = OFF)
{
    WinSet, Transparent, 235, A
}
else
{
    WinSet, Transparent, OFF, A
}
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

; Command Prompt
#Enter::
Run, cmd /K cd /
return

; Wsl prompt
#+Enter::
Run, wsl.exe
return

; Close focused window (Including Explorer.exe)
;#q::
;WinClose, A
;return

; Close focused window
#q::
WinGetTitle, Title, A
PostMessage, 0x112, 0xF060,,, %Title% 
return

; Force Kill a window
#+q::
WinKill, A
return

; Choose Virtualbox VM
#F8::
Run, vboxes,,Hide
return

; Disk Mounter
#F9::
Run, powershell mounter.ps1,,Hide
return

; Reload autohotkey script
^!r::Reload
return

; Globals
DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

; Check if process is running
ProcessExist(Name) {
	Process,Exist,%Name%
	return Errorlevel
}

; This Function activate a program if already running.
; Else, it open a new instance of the program
ActivateOrOpen(window, program)
{
	; check if window exists
	if WinExist(window)
	{
		WinActivate  ; Uses the last found window.
	}
	else
	{   ; else start requested program
		 Run cmd /c "start ^"^" ^"%program%^"",, Hide ;use cmd in hidden mode to launch requested program
		 WinWait, %window%,,5		; wait up to 5 seconds for window to exist
		 IfWinNotActive, %window%, , WinActivate, %window%
		 {
			  WinActivate  ; Uses the last found window.
		 }
	}
	return
}

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