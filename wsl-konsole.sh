#!/usr/bin/env bash
set -e

PS_SCRIPT="$(wslpath -w "$PWD/wsl-konsole.ps1")"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT"
