# Based on:
# https://www.advancedinstaller.com/how-to-handle-fonts-on-windows-with-powershell.html

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FontSourceDir = Join-Path $ScriptDir "nerdfonts"
$FontDestinationDir = "C:\Windows\Fonts"
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Get-ChildItem -Path $FontSourceDir -Filter *.ttf | ForEach-Object {
    $FontSourcePath = $_.FullName
    $FontFileName = $_.Name
    $FontDestinationPath = Join-Path $FontDestinationDir $FontFileName
    $FontRegistryName = "$($_.BaseName) (TrueType)"

    if (-Not (Test-Path -Path $FontDestinationPath)) {
        Copy-Item -Path $FontSourcePath -Destination $FontDestinationPath -Force
    }

    if (-Not (Get-ItemProperty -Path $FontRegPath -Name $FontRegistryName -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $FontRegPath -Name $FontRegistryName -PropertyType String -Value $FontFileName -Force
    }
}

Read-Host "Press Enter to close"
