#!/usr/bin/env bash
set -e

PS_SCRIPT="$(wslpath -w "$PWD/wsl-install-fonts.ps1")"

powershell.exe -NoProfile -Command "
Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', '$PS_SCRIPT'
)
"
