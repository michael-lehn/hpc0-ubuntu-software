$Desktop = [Environment]::GetFolderPath("Desktop")

$VbsPath = Join-Path $Desktop "Konsole.vbs"
$LnkPath = Join-Path $Desktop "Konsole.lnk"

@'
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "wsl.exe --distribution Ubuntu --exec bash -lc ""cd ~ && exec konsole""", 0, False
'@ | Set-Content -Path $VbsPath -Encoding ASCII

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($LnkPath)
$Shortcut.TargetPath = $VbsPath
$Shortcut.IconLocation = "C:\Windows\System32\wsl.exe,0"
$Shortcut.Save()
