; <COMPILER: v1.1.33.02>
minival := false
Numpad0 & Numpad3::Send, {Media_Next}
Numpad0 & Numpad1::Send, {Media_Prev}
^Up::Send, {Volume_Up}
^Down::Send, {Volume_Down}
!Up::unmuteWithoutToggle()
!Down::Send, {Volume_Mute}
Numpad0 & Numpad6::Send, ^{s}
Numpad0 & Numpad9::Send, ^{r}
Numpad0 & Numpad2::send, {Media_Play_Pause}
Numpad0 & Numpad4::playlist("one",minival)
Numpad0 & Numpad7::playlist("fav", minival)
^PgUp::playlist("two", minival)
Numpad0 & Numpad8::Send, +{Right}
Numpad0 & Numpad5::Send, +{Left}
^;::search(false, false, false)

^End::jtogglespotify()
playlist(cmd, min)
{
    MouseGetPos, origx, origy, origwin
    WinGetClass, origin, A
    ActivateSpotify(origin)
    MsgBox, 1, Title, %spotifywin%
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
    minimizeifo(origwin , spotifywin)
}
minimizeifo(origwin, spotifywin)
{
    if (origwin == spotifywin)
        {
        Return
        }
    else if (origwin != spotifywin)
        {
        WinMinimize, A
        Reactivate(origin, origwin, origx, origy, min)
        Return
        }
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
    Send, {Enter}
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
search(minSpotify, minChrome, reactivate)
{
    MouseGetPos, origx, origy, origwin
    WinGetClass, origin, A
    ActivateSpotify(origin)
    WinGetActiveStats, title, width, height, winX, winY
    if (minSpotify = true)
        WinMinimize, A
    WinActivate ahk_exe chrome.exe
    WinGetClass, current, A
    if (current = origin)
        MouseMove, %origx%, %origy%
    oc := ClipboardAll
    Clipboard := title
    Sleep, 150
    Send, ^{t}
    Send, !{d}
    Send, ^{v}
    Sleep, 150
    Send, {Enter}
    Clipboard := oc
    if (minChrome = true)
        WinMinimize, Spotify Premium
    if (reactivate = true and current != origin)
        WinActivate, ahk_id %origwin%
    if (reactivate = true or current = origin)
        MouseMove, %origx%, %origy%
    Return
}
unmuteWithoutToggle()
{
    SoundGet, MuteState, Master, Mute
    if MuteState=On
        send {Volume_Mute}
    Return
}
volume(val, min)
{
    MouseGetPos, origx, origy, origwin
    WinGetClass, origin, A
    ActivateSpotify(origin)
    if (val = "up")
        Send, ^{Up}
    else if (val = "dn")
        Send, ^{Down}
    Reactivate(origin, origwin, origx, origy, min)
    Return
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
    Return
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
DetectHiddenWindows, On
getSpotifyHwnd() 
{
    WinGet, spotifyHwnd, ID, ahk_exe Spotify.exe
    spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
    spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
    Return spotifyHwnd
}
spotifyKey(key) {
    spotifyHwnd := getSpotifyHwnd()
    ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
    ControlSend, , %key%, ahk_id %spotifyHwnd%
    Return
}
jplaypause()
{
    DetectHiddenWindows, On 
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
jtogglespotify()
{
    spotifyHwnd := getSpotifyHwnd()
    WinGet, style, Style, ahk_id %spotifyHwnd%
    if (style & 0x10000000) {
        WinHide, ahk_id %spotifyHwnd%
    } Else {
        WinShow, ahk_id %spotifyHwnd%
        WinActivate, ahk_id %spotifyHwnd%
    }
    Return
}
DetectHiddenWindows, On