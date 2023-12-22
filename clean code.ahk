#SingleInstance force
#NoEnv
SetBatchLines, -1

handler := Func("guilaun").Bind(param1, param2)
Menu, Tray, Add, Change Hotkeys, % handler
minival := false
#ctrls = 12 ;no of Hotkeys
Loop,% #ctrls
    {

        Gui, Add, Text, xm, Enter Hotkey #%A_Index%:

        IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%

        If savedHK%A_Index% ;Check for saved hotkeys in INI file.
            Hotkey,% savedHK%A_Index%, Label%A_Index% ;Activate saved hotkeys if found.

        StringReplace, noMods, savedHK%A_Index%, ~ ;Remove tilde (~) and Win (#) modifiers...

        StringReplace, noMods, noMods, #,,UseErrorLevel ;They are incompatible with hotkey controls (cannot be shown).

        Gui, Add, Hotkey, x+5 vHK%A_Index% gLabel, %noMods% ;Add hotkey controls and show saved hotkeys.

        Gui, Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win ;Add checkboxes to allow the Windows key (#) as a modifier...

    } ;Check the box if Win modifier is used.

    
guilaun()
{
    global
    Gui, Destroy,
    Suspend, On
    Gui, add, text, xm,1=next, 2=prev, 3=play/pause, 4=vol-up, 5=vol-down
    Gui, Add, Text, xm+1,6=toggle randomize, 7=toggle loop, 8=launch/minimize/maximaze spotify
    Gui, Add, Text, xm+1,9=Save song to favorites, 10=turn off monitor
    Gui, Add, Text, xm+1,11=Skip forward 15 sec, 12=Move back 15 sec 
    Gui, Add, Text, xm+1,*for random and loop controls spotify needs to be in topmost window
    Loop,% #ctrls
        {
    
            Gui, Add, Text, xm, Enter Hotkey #%A_Index%:
    
            IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%
    
            If savedHK%A_Index% ;Check for saved hotkeys in INI file.
                Hotkey,% savedHK%A_Index%, Label%A_Index% ;Activate saved hotkeys if found.
    
            StringReplace, noMods, savedHK%A_Index%, ~ ;Remove tilde (~) and Win (#) modifiers...
    
            StringReplace, noMods, noMods, #,,UseErrorLevel ;They are incompatible with hotkey controls (cannot be shown).
    
            Gui, Add, Hotkey, x+5 vHK%A_Index% gLabel, %noMods% ;Add hotkey controls and show saved hotkeys.
    
            Gui, Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win ;Add checkboxes to allow the Windows key (#) as a modifier...
    
        } ;Check the box if Win modifier is used.
    Gui, Show,,Dynamic Hotkeys
    return
    GuiClose:
    Suspend, Off
    Gui, Cancel,
    Return

}

Label:
    If A_GuiControl in +,^,!,+^,+!,^!,+^! ;If the hotkey contains only modifiers, return to wait for a key.
        return
    num := SubStr(A_GuiControl,3) ;Get the index number of the hotkey control.
    If (HK%num% != "") { ;If the hotkey is not blank...
        Gui, Submit, NoHide
        If CB%num% ;  If the 'Win' box is checked, then add its modifier (#).
            HK%num% := "#" HK%num%
        If !RegExMatch(HK%num%,"[#!\^\+]") ;  If the new hotkey has no modifiers, add the (~) modifier.
            HK%num% := "~" HK%num% ;    This prevents any key from being blocked.
        Loop,% #ctrls
            If (HK%num% = savedHK%A_Index%) { ;  Check for duplicate hotkey...
                dup := A_Index
                Loop,6 {
                    GuiControl,% "Disable" b:=!b, HK%dup% ;    Flash the original hotkey to alert the user.
                    Sleep,200
                }
                GuiControl,,HK%num%,% HK%num% :="" ;    Delete the hotkey and clear the control.
                break
            }
    }
    If (savedHK%num% || HK%num%)
        setHK(num, savedHK%num%, HK%num%)
return

;These labels contain any commands for their respective hotkeys to perform.
Label1:
    Send, {Media_Next}
return

Label2:
    Send, {Media_Prev}
return

Label3:
    IfWinExist, YouTube
    {
        WinActivate, ahk_class Chrome_WidgetWin_0
        jplaypause()
        WinMinimize, ahk_class Chrome_WidgetWin_0
    }
    else 
        Send, {Media_Play_Pause}
return

Label4:
    Send, {Volume_Up}
return

Label5:
    Send, {Volume_Down}
return

Label6:
    Send, ^{s}
return

Label7:
    Send, ^{r}
return

Label8:
    spotifyminmaxtoggle()
return

Label9:
    playlist("fav", minival)
return

Label10:
    SendMessage 0x112, 0xF140, 0, , Program Manager  ; Monitor off
return

Label11:
    Send, +{Right}
return

Label12:
    Send, +{Left}
return


setHK(num,INI,GUI)
{
    If INI
        Hotkey, %INI%, Label%num%, Off
    If GUI
        Hotkey, %GUI%, Label%num%, On
    IniWrite,% GUI ? GUI:null, Hotkeys.ini, Hotkeys, %num%
    savedHK%num% := HK%num%
    TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
}

ActivateSpotify(origin)
{
    spotify = Chrome_WidgetWin_0
    if (origin != spotify)
    {
        WinActivate, ahk_class Chrome_WidgetWin_0
        Click, 100, 10
        Return
    }
}

Reactivate(origin, origwin, origx, origy, min)
{
    WinGetClass, current, A
    minimizeif(origin, min)
    if (origin != current)
    {
        WinActivate, ahk_id %origwin%
        MouseMove, %origx%, %origy%
        Return
    }
    else
        MouseMove, %origx%, %origy%
    Return
}

spotifyminmaxtoggle()
{

    IfWinNotExist, ahk_class Chrome_WidgetWin_0
    {
        username := A_UserName
        basepath := "C:\Users\"
        remainingpath:= "\AppData\Roaming\Spotify\Spotify.exe"
        finalpath := basepath username remainingpath
        Run, %finalpath%
    }
    IfWinNotActive, ahk_class Chrome_WidgetWin_0
    {
        WinActivate, ahk_class Chrome_WidgetWin_0
    }
    else
        WinMinimize, ahk_class Chrome_WidgetWin_0

    Return
}

minimizeif(origin, min)
{
    windows_file_explorer = CabinetWClass
    rainmeterskin = RainmeterMeterWindow
    spotify = Chrome_WidgetWin_0
    rainmeter = #32770
    desktop = WorkerW
    if (min = false)
    {
        if (origin = windows_file_explorer)
            WinMinimize, A
        else if (origin = rainmeterskin)
            WinMinimize, A
        else if (origin = rainmeter)
            WinMinimize, A
        else if (origin = desktop)
            WinMinimize, A
        else
            Return
        Return
    }
    else if (min = true)
    {
        if (origin = spotify)
            Return
        else
            WinMinimize, A
        Return
    }
    Return
}

playlist(cmd, min)
{
    MouseGetPos, origx, origy, origwin
    WinGetClass, origin, A
    ActivateSpotify(origin)
    WinGetActiveStats, winTitle, width, height, winX, winY
    y := height - 70
    Click, right, 30, %y%
    Sleep, 150
    if (cmd = "fav")
        playlistFav()
    else if (cmd = "one")
        playlistOne()
    else if (cmd = "two")
        playlistTwo()
    else if (cmd = "radio")
        playlistRadio()
    Reactivate(origin, origwin, origx, origy, min)
    Return
}

playlistRadio()
{
    WinMaximize, ahk_class Chrome_WidgetWin_0
    Sleep, 50
    Send, {Up}{Up}{Up}{Up}{Up}{Up}{Up}{Enter}
    Sleep, 1050
    Click, Left, 444, 386

}

playlistFav()
{
    Send, {Up}{Up}{Up}{Enter}
    Return
}

playlistOne()
{
    Send, {Up}{Up}{Right}{Down}{Enter}
    Sleep, 10
    Send, {Down}{Down}{Enter}
    Return
}

playlistTwo()
{
    Send, {Up}{Up}{Right}{Down}{Down}{Down}{Down}{Down}{Down}{Down}
    Send, {Down}{Down}{Down}{Down}{Down}{Right}{Down}{Enter}
    Sleep 10
    Send, {Enter}
    Return
}

miniskip(val, min)
{
    MouseGetPos, origx, origy, origwin
    WinGetClass, origin, A
    ActivateSpotify(origin)
    WinGetActiveStats, winTitle, width, height, winX, winY
    g := 0
    h := height - 5
    PixelGetColor, color, 5, %h%
    green := 0x54B91D
    if (color = green)
        g := 30
    percent := 22.5938 * ln(.0021 * width)
    quarter := (width / 100) * (percent / 4)
    quarter := quarter * val
    x := width / 2 + quarter
    y := height - 27 - g
    Click, %x%, %y%
    Reactivate(origin, origwin, origx, origy, min)
    Return
}

DetectHiddenWindows, On

getSpotifyHwnd()
{
    WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
    spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
    spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
    Return spotifyHwnd
}

spotifyKey(key)
{
    spotifyHwnd := getSpotifyHwnd()
    ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
    ControlSend, , %key%, ahk_id %spotifyHwnd%
    Return
}

jplaypause()
{
    WinGet, winInfo, List, ahk_exe Spotify.exe
    Loop, %winInfo%
    {
        thisID := winInfo%A_Index%
        ControlFocus , , ahk_id %thisID%
        ControlSend, , {Space}, ahk_id %thisID%
    }
    return
}

jnext()
{
    spotifyKey("^{Right}")
    Return
}

jprev()
{
    spotifyKey("^{Left}")
    Return
}

jfwd()
{
    spotifyKey("+{Right}")
    Return
}

jback()
{
    spotifyKey("+{Left}")
    Return
}

jvolup()
{
    spotifyKey("^{Up}")
    Return
}

jvoldwn()
{
    spotifyKey("^{Down}")
    Return
}

isWindowFullScreen( winTitle ) {
	;checks if the specified window is full screen
	
	winID := WinExist( winTitle )

	If ( !winID )
		Return false

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

DetectHiddenWindows, Off