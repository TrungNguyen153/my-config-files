# Installs a "Neovide WSL" right-click context menu entry for this user.
# - No admin needed (writes to HKCU only).
# - Detects neovide.exe via PATH at install time -- no hardcoded paths.
# - Three locations:
#     * (file)             -> right-click a file -> Neovide WSL
#     Directory            -> right-click a folder -> opens that folder
#     Directory\Background -> right-click empty space in a folder -> opens current dir
#
# Run once:  powershell -ExecutionPolicy Bypass -File .\install-neovide-wsl-context-menu.ps1
# Uses the .NET Registry API directly so the literal `*` key name (Windows'
# "all files" convention) is not interpreted as a PowerShell wildcard.

[CmdletBinding()]
param(
    [string]$NvimWslPath = '/usr/local/bin/nvim',
    [string]$Label       = 'Neovide WSL',
    [string]$KeyName     = 'NeovideWSL'
)

$ErrorActionPreference = 'Stop'

$neovide = (Get-Command neovide -ErrorAction SilentlyContinue).Source
if (-not $neovide) {
    Write-Error "neovide.exe not on PATH. Install via 'scoop install neovide' (or winget/choco) and re-run."
    exit 1
}
Write-Host "Found neovide: $neovide" -ForegroundColor Cyan

# %1 -> clicked file/folder path. %V -> current folder path (background click).
$cmdForPath = "`"$neovide`" --wsl --neovim-bin $NvimWslPath `"%1`""
$cmdForBg   = "`"$neovide`" --wsl --neovim-bin $NvimWslPath `"%V`""
$iconValue  = "`"$neovide`",0"

$targets = @(
    @{ Path = "SOFTWARE\Classes\*\shell\$KeyName";                    Cmd = $cmdForPath; Desc = 'file'       },
    @{ Path = "SOFTWARE\Classes\Directory\shell\$KeyName";            Cmd = $cmdForPath; Desc = 'folder'     },
    @{ Path = "SOFTWARE\Classes\Directory\Background\shell\$KeyName"; Cmd = $cmdForBg;   Desc = 'background' }
)

foreach ($t in $targets) {
    # CreateSubKey is idempotent: creates if missing, opens if exists.
    $verb = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($t.Path)
    $verb.SetValue('',     $Label)
    $verb.SetValue('Icon', $iconValue)

    $cmd  = $verb.CreateSubKey('command')
    $cmd.SetValue('', $t.Cmd)
    $cmd.Close()
    $verb.Close()

    Write-Host ("  registered for {0,-10} -> {1}" -f $t.Desc, $t.Cmd)
}

Write-Host ''
Write-Host "Done. Right-click a file/folder/folder-background -> '$Label'." -ForegroundColor Green
Write-Host "Windows 11: entry hides behind 'Show more options' by default (or Shift+Right-click)."
