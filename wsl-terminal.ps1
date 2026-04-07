$Name = "WSL Ubuntu"

$WtPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
$Arguments = '-p "Ubuntu" -d ~'

$StartMenuShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$Name.lnk"
$DesktopShortcut   = "$env:USERPROFILE\Desktop\$Name.lnk"

$WshShell = New-Object -ComObject WScript.Shell

foreach ($ShortcutPath in @($StartMenuShortcut, $DesktopShortcut)) {
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $WtPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.IconLocation = "$WtPath,0"
    $Shortcut.Save()
    Write-Host "Created: $ShortcutPath"
}
