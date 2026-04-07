$paths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$settingsPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Error "Windows Terminal settings.json not found."
    exit 1
}

Write-Host "Using: $settingsPath"

$backupPath = "$settingsPath.bak"
Copy-Item $settingsPath $backupPath -Force
Write-Host "Backup written to: $backupPath"

$jsonText = Get-Content $settingsPath -Raw
$config = $jsonText | ConvertFrom-Json 

# keybindings anlegen, falls nicht vorhanden
if (-not ($config.PSObject.Properties.Name -contains 'keybindings')) {
    $config | Add-Member -NotePropertyName keybindings -NotePropertyValue @()
}

# Alles rauswerfen, was ctrl+c / ctrl+v / ctrl+shift+c / ctrl+shift+v betrifft
$filtered = @()
foreach ($kb in $config.keybindings) {
    $keys = $kb.keys
    if ($keys -is [System.Array]) {
        $remove = $false
        foreach ($k in $keys) {
            if ($k -in @('ctrl+c', 'ctrl+v', 'ctrl+shift+c', 'ctrl+shift+v')) {
                $remove = $true
                break
            }
        }
        if (-not $remove) {
            $filtered += $kb
        }
    } else {
        if ($keys -notin @('ctrl+c', 'ctrl+v', 'ctrl+shift+c', 'ctrl+shift+v')) {
            $filtered += $kb
        }
    }
}
$config.keybindings = $filtered

# Neue Bindings setzen
$config.keybindings += [pscustomobject]@{
    id   = "Terminal.CopyToClipboard"
    keys = "ctrl+shift+c"
}
$config.keybindings += [pscustomobject]@{
    id   = "Terminal.PasteFromClipboard"
    keys = "ctrl+shift+v"
}

# Ctrl+C / Ctrl+V explizit entbinden
$config.keybindings += [pscustomobject]@{
    id   = "Unbound"
    keys = "ctrl+c"
}
$config.keybindings += [pscustomobject]@{
    id   = "Unbound"
    keys = "ctrl+v"
}

$config | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding utf8

Write-Host "Done. Fully quit and restart Windows Terminal."
