# Removes the "Neovide WSL" context menu entries created by install-neovide-wsl-context-menu.ps1.
# Run: powershell -ExecutionPolicy Bypass -File .\uninstall-neovide-wsl-context-menu.ps1

[CmdletBinding()]
param([string]$KeyName = 'NeovideWSL')

$ErrorActionPreference = 'Stop'

$paths = @(
    "SOFTWARE\Classes\*\shell\$KeyName",
    "SOFTWARE\Classes\Directory\shell\$KeyName",
    "SOFTWARE\Classes\Directory\Background\shell\$KeyName"
)

foreach ($p in $paths) {
    try {
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($p, $false)
        Write-Host "removed HKCU\$p"
    } catch {
        Write-Host "not present HKCU\$p"
    }
}

Write-Host "Done." -ForegroundColor Green
