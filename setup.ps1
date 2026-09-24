<#
.SYNOPSIS
    Sets up a Windows machine from this repo: system tweaks, scoop packages
    and config links. Safe to re-run; -WhatIf reports without changing
    anything.

.DESCRIPTION
    On a new machine, one line in PowerShell. It installs scoop and git,
    clones the repo into -Dir, then carries on from the clone:
        [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; & ([scriptblock]::Create((irm https://raw.githubusercontent.com/TrungNguyen153/my-config-files/master/setup.ps1)))

    From a clone:
        .\setup.ps1                        everything
        .\setup.ps1 -WhatIf                dry run
        .\setup.ps1 -Steps links           only the config links
        .\setup.ps1 -Groups core           only the packages the configs need

    From a fresh shell, if scripts are blocked:
        powershell -ExecutionPolicy Bypass -File .\setup.ps1

    Steps:
        system    execution policy for scoop; UAC prompts off for admins;
                  never sleep, on AC or battery
        packages  scoop apps by group (core, dev, apps), plus the few things
                  scoop doesn't carry: a WezTerm fallback font, rustup, node
        links     junctions from where the programs look for their config to
                  the folders in this repo; nothing is ever deleted

    Written for Windows PowerShell 5.1 and kept to plain ASCII: 5.1 reads a
    BOM-less script in the ANSI code page. Never calls exit outside the
    elevated re-run, because run as a scriptblock that would close the shell.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # system, packages, links. A comma list in one string works too.
    [string[]]$Steps = @('system', 'packages', 'links'),
    # core, dev, apps.
    [string[]]$Groups = @('core', 'dev', 'apps'),
    # Where a new machine clones the repo. Matches WezTerm's projects_dir.
    [string]$Dir = (Join-Path $env:USERPROFILE 'Desktop\Workspace\my-config-files'),
    # Where to clone from. A local path works for testing.
    [string]$Repo = 'https://github.com/TrungNguyen153/my-config-files',
    # Internal: the elevated re-run of this file for admin-only tasks.
    [string[]]$AdminTasks = @()
)

# ------------------------------------------------------------------- data

$AllSteps = @('system', 'packages', 'links')
$AllGroups = @('core', 'dev', 'apps')
$AllAdminTasks = @('uac', 'vcredist')

# bucket/app. Buckets are added only when an app from them is missing.
$Packages = [ordered]@{
    # What the configs in this repo need.
    core = @(
        'main/git', 'main/7zip', 'main/neovim', 'extras/neovide', 'versions/wezterm-nightly',
        'main/nu', 'extras/carapace-bin', 'main/yazi', 'main/ripgrep', 'main/fd',
        'nerd-fonts/JetBrainsMono-NF'
    )
    # Toolchains. llvm ships clangd. tree-sitter, rustup and node are added
    # below, each only when its command is missing.
    dev  = @('main/gcc', 'main/llvm', 'main/make', 'main/cmake', 'main/sed', 'versions/python311', 'main/nvm')
    apps = @(
        'extras/vscode', 'extras/googlechrome', 'extras/notepadplusplus', 'extras/fork',
        'extras/putty', 'extras/winscp', 'extras/dnspyex', 'extras/debugviewpp',
        'sysinternals/process-explorer', 'sysinternals/tcpview', 'main/ngrok',
        'extras/antigravity', 'nerd-fonts/RobotoMono-NF-Propo'
    )
}

# WezTerm's fallback for symbols JetBrainsMono lacks (see
# .config/wezterm/lua/appearance.lua). No scoop bucket carries it.
$SymbolsFont = @{
    Prefix = 'Noto Sans Symbols 2'
    Name   = 'Noto Sans Symbols 2 (TrueType)'
    File   = 'NotoSansSymbols2-Regular.ttf'
    Url    = 'https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssymbols2/NotoSansSymbols2-Regular.ttf'
}

$RustupInit = 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe'

# powercfg -change name -> the subgroup and setting to read it back from.
$PowerSettings = [ordered]@{
    'monitor-timeout'   = @('SUB_VIDEO', 'VIDEOIDLE')
    'disk-timeout'      = @('SUB_DISK', 'DISKIDLE')
    'standby-timeout'   = @('SUB_SLEEP', 'STANDBYIDLE')
    'hibernate-timeout' = @('SUB_SLEEP', 'HIBERNATEIDLE')
}

$UacKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

# Where the elevated re-run leaves its results for the parent to read.
$AdminResultFile = Join-Path $env:TEMP 'my-config-setup-admin.json'

# Config folders in this repo, and where the programs look for them. Carry
# lists files that live beside the config but belong to the user (Nushell
# keeps its history in its config folder): they move into the repo folder,
# which .gitignore keeps them out of, instead of being left in a backup.
$Links = @(
    @{ Name = 'nvim'; Source = '.config\nvim'; Target = (Join-Path $env:LOCALAPPDATA 'nvim') }
    @{ Name = 'wezterm'; Source = '.config\wezterm'; Target = (Join-Path $env:USERPROFILE '.config\wezterm') }
    @{
        Name = 'nushell'; Source = '.config\nushell'; Target = (Join-Path $env:APPDATA 'nushell')
        Carry = @('history.txt', 'history.sqlite3', 'history.sqlite3-wal', 'history.sqlite3-shm', 'plugin.msgpackz')
    }
    @{ Name = 'neovide'; Source = '.config\neovide'; Target = (Join-Path $env:APPDATA 'neovide') }
)

# ---------------------------------------------------------------- helpers

function New-Result([string]$Item, [string]$Status, [string]$Detail = '') {
    # Status: ok (already fine), changed, would (dry run), failed, note.
    [pscustomobject]@{ Item = $Item; Status = $Status; Detail = $Detail }
}

function Write-Step([string]$Name) {
    Write-Host ''
    Write-Host "== $Name" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-Admin {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 'packages,links' -> packages, links. `powershell -File` hands a comma
# list over as one string, so every list parameter goes through this.
function ConvertTo-List([string[]]$Value) {
    @($Value | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
}

function Assert-Allowed([string]$What, [string[]]$Value, [string[]]$Allowed) {
    $bad = @($Value | Where-Object { $_ -notin $Allowed })
    if ($bad) {
        throw "unknown $What '$($bad -join "', '")'; use: $($Allowed -join ', ')"
    }
}

# ~ and relative paths resolved against PowerShell's location, the way
# Test-Path sees them. .NET and git would use the process directory instead,
# which 5.1 does not move on Set-Location.
function Resolve-UserPath([string]$Path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

# '\\?\C:\x\' -> 'C:\x', so link targets compare equal however Windows
# chose to spell them.
function Get-NormalizedPath([string]$Path) {
    $p = $Path -replace '^\\(\\\?|\?\?)\\', ''
    [IO.Path]::GetFullPath((Resolve-UserPath $p)).TrimEnd('\')
}

# ---------------------------------------------------------------- system

function Set-UserExecutionPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $item = 'execution policy'
    $current = Get-ExecutionPolicy -Scope CurrentUser
    if ($current -in 'RemoteSigned', 'Unrestricted', 'Bypass') {
        return New-Result $item 'ok' "CurrentUser: $current"
    }
    if (-not $PSCmdlet.ShouldProcess('CurrentUser', 'Set-ExecutionPolicy RemoteSigned')) {
        return New-Result $item 'would' 'CurrentUser -> RemoteSigned'
    }
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    }
    catch {
        # Raised when a Process-scope policy (powershell -ExecutionPolicy
        # Bypass) overrides it, after the change has been made anyway.
        if ($_.FullyQualifiedErrorId -notlike 'ExecutionPolicyOverride*') {
            return New-Result $item 'failed' $_.Exception.Message
        }
    }
    New-Result $item 'changed' 'CurrentUser -> RemoteSigned'
}

# powercfg /query output -> the current AC and DC values. They are the last
# two hex numbers, whatever language the labels are in.
function ConvertFrom-PowerQuery([string[]]$Lines) {
    $hex = @($Lines | ForEach-Object {
            if ($_ -match '(0x[0-9a-fA-F]+)\s*$') { [Convert]::ToInt64($Matches[1], 16) }
        })
    if ($hex.Count -lt 2) {
        return @{ AC = $null; DC = $null }
    }
    @{ AC = $hex[-2]; DC = $hex[-1] }
}

# Screen, disk, sleep and hibernate timeouts to never, plugged in and on
# battery alike.
function Set-NeverSleep {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $item = 'power: never sleep'
    try {
        $todo = @()
        foreach ($name in $PowerSettings.Keys) {
            $setting = $PowerSettings[$name]
            $now = ConvertFrom-PowerQuery (powercfg /query SCHEME_CURRENT $setting[0] $setting[1])
            if ($now.AC -ne 0) { $todo += "$name-ac" }
            if ($now.DC -ne 0) { $todo += "$name-dc" }
        }
        if (-not $todo) {
            return New-Result $item 'ok' 'AC and battery'
        }
        if (-not $PSCmdlet.ShouldProcess('active power plan', "set $($todo -join ', ') to never")) {
            return New-Result $item 'would' ($todo -join ', ')
        }
        foreach ($t in $todo) {
            powercfg /change $t 0
            if ($LASTEXITCODE -ne 0) { throw "powercfg /change $t 0 exited with $LASTEXITCODE" }
        }
        New-Result $item 'changed' ($todo -join ', ')
    }
    catch {
        New-Result $item 'failed' $_.Exception.Message
    }
}

function Get-UacValue {
    (Get-ItemProperty -LiteralPath $UacKey -ErrorAction SilentlyContinue).ConsentPromptBehaviorAdmin
}

# ----------------------------------------------------------------- scoop

# scoop is a .ps1 running in a child scope: without this it would inherit
# -WhatIf/-Confirm, and its own file cmdlets would skip or prompt.
function Invoke-Scoop {
    $WhatIfPreference = $false
    $ConfirmPreference = 'High'
    & scoop @args
}

# Apps scoop has properly installed. A failed install stays listed with
# Info 'Install failed', so it is not counted.
function Get-InstalledApps {
    @(Invoke-Scoop list 6>$null | Where-Object { $_.Info -notmatch 'Install failed' } | ForEach-Object { $_.Name })
}

function Get-MissingApps([string[]]$Wanted, [string[]]$Installed) {
    @($Wanted | Where-Object { ($_ -split '/')[-1] -notin $Installed })
}

function Initialize-Scoop {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if (Test-Command 'scoop') {
        return New-Result 'scoop' 'ok'
    }
    if (-not $PSCmdlet.ShouldProcess('scoop', 'install from get.scoop.sh')) {
        return New-Result 'scoop' 'would' 'install from get.scoop.sh'
    }
    try {
        $installer = [scriptblock]::Create((Invoke-RestMethod -UseBasicParsing 'https://get.scoop.sh' -ErrorAction Stop))
        # The installer refuses to run elevated unless told to.
        if (Test-Admin) { & $installer -RunAsAdmin } else { & $installer }
        if (-not (Test-Command 'scoop')) { throw 'scoop is still not on PATH after installing it' }
        New-Result 'scoop' 'changed' 'installed'
    }
    catch {
        New-Result 'scoop' 'failed' $_.Exception.Message
    }
}

# scoop exits 0 even when an install fails, so each app is judged by what
# scoop lists afterwards.
function Install-ScoopApps {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Apps)
    $haveBuckets = @(Invoke-Scoop bucket list | ForEach-Object { $_.Name })
    $needBuckets = @($Apps | ForEach-Object { ($_ -split '/')[0] } | Where-Object { $_ -ne 'main' } | Select-Object -Unique)
    foreach ($bucket in $needBuckets) {
        if ($bucket -notin $haveBuckets -and $PSCmdlet.ShouldProcess($bucket, 'scoop bucket add')) {
            Invoke-Scoop bucket add $bucket | Out-Host
        }
    }
    $tried = @()
    foreach ($app in $Apps) {
        # One app per call: an abort inside `scoop install a b c` skips the rest.
        if ($PSCmdlet.ShouldProcess($app, 'scoop install')) {
            Invoke-Scoop install $app | Out-Host
            $tried += $app
        }
        else {
            New-Result "app $(($app -split '/')[-1])" 'would' "scoop install $app"
        }
    }
    if ($tried) {
        $now = @(Get-InstalledApps)
        foreach ($app in $tried) {
            $name = ($app -split '/')[-1]
            if ($name -in $now) {
                New-Result "app $name" 'changed' 'installed'
            }
            else {
                New-Result "app $name" 'failed' "scoop install $app did not finish; see its output above"
            }
        }
    }
}

# ---------------------------------------------------- beyond scoop's reach

function Test-FontRegistered {
    param(
        [string]$Prefix,
        [string[]]$Keys = @(
            'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts',
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        )
    )
    foreach ($key in $Keys) {
        $values = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        if ($values -and @($values.PSObject.Properties.Name | Where-Object { $_ -like "$Prefix*" }).Count) {
            return $true
        }
    }
    $false
}

function Install-SymbolsFont {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $item = 'font Noto Sans Symbols 2'
    if (Test-FontRegistered $SymbolsFont.Prefix) {
        return New-Result $item 'ok'
    }
    if (-not $PSCmdlet.ShouldProcess($SymbolsFont.Name, 'download and install for this user')) {
        return New-Result $item 'would' 'download and install for this user'
    }
    try {
        $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
        [void][IO.Directory]::CreateDirectory($dir)
        $file = Join-Path $dir $SymbolsFont.File
        Invoke-WebRequest -UseBasicParsing -Uri $SymbolsFont.Url -OutFile $file -ErrorAction Stop
        $key = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
        # Test first: New-Item -Force on an existing key would wipe its values.
        if (-not (Test-Path -LiteralPath $key)) {
            New-Item -Path $key -ErrorAction Stop | Out-Null
        }
        New-ItemProperty -LiteralPath $key -Name $SymbolsFont.Name -Value $file -PropertyType String -Force -ErrorAction Stop | Out-Null
        New-Result $item 'changed' 'installed for this user; restart apps to see it'
    }
    catch {
        New-Result $item 'failed' $_.Exception.Message
    }
}

# rustup from its own installer rather than scoop, so the toolchain lives in
# ~\.cargo as on the existing machines. Nightly rustfmt is what rustaceanvim
# formats with ('+nightly').
function Install-Rustup {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $item = 'rustup'
    if (Test-Command 'rustup') {
        return New-Result $item 'ok'
    }
    if (-not $PSCmdlet.ShouldProcess('rustup', 'rustup-init -y, then the nightly toolchain with rustfmt')) {
        return New-Result $item 'would' 'rustup-init -y, nightly rustfmt'
    }
    try {
        $init = Join-Path $env:TEMP 'rustup-init.exe'
        Invoke-WebRequest -UseBasicParsing -Uri $RustupInit -OutFile $init -ErrorAction Stop
        & $init -y --default-toolchain stable --profile default | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "rustup-init exited with $LASTEXITCODE" }
        $cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { Join-Path $env:USERPROFILE '.cargo' }
        $cargoBin = Join-Path $cargoHome 'bin'
        # rustup-init only updates PATH in the registry.
        $env:Path = "$cargoBin;$env:Path"
        & (Join-Path $cargoBin 'rustup.exe') toolchain install nightly --profile minimal --component rustfmt | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "installing the nightly toolchain exited with $LASTEXITCODE" }
        New-Result $item 'changed' 'stable (default) and nightly rustfmt'
    }
    catch {
        New-Result $item 'failed' $_.Exception.Message
    }
}

# Without Visual Studio's C++ build tools, Rust (msvc) compiles but cannot
# link. rustup-init only warns about it, so say so in the summary.
function Test-MsvcTools {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if ((Test-Path -LiteralPath $vswhere) -and
        (& $vswhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)) {
        return
    }
    New-Result 'msvc build tools' 'note' 'not found: install Visual Studio C++ build tools before building Rust'
}

function Install-NodeLts {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $item = 'node (nvm lts)'
    if (Test-Command 'node') {
        return New-Result $item 'ok'
    }
    if (-not (Test-Command 'nvm')) {
        if ($WhatIfPreference) {
            return New-Result $item 'would' 'nvm install lts, nvm use lts (after nvm)'
        }
        return New-Result $item 'failed' 'nvm is not installed'
    }
    if (-not $PSCmdlet.ShouldProcess('node', 'nvm install lts; nvm use lts')) {
        return New-Result $item 'would' 'nvm install lts, nvm use lts'
    }
    try {
        & nvm install lts | Out-Host
        & nvm use lts | Out-Host
        # nvm exits 0 even when it fails, so look for node itself.
        $link = if ($env:NVM_SYMLINK) { $env:NVM_SYMLINK } else { [Environment]::GetEnvironmentVariable('NVM_SYMLINK', 'User') }
        if (-not $link -or -not (Test-Path -LiteralPath (Join-Path $link 'node.exe'))) {
            throw 'node.exe is missing after nvm use'
        }
        if ($env:Path -notlike "*$link*") { $env:Path = "$link;$env:Path" }
        New-Result $item 'changed' 'installed the LTS release'
    }
    catch {
        New-Result $item 'failed' $_.Exception.Message
    }
}

function Invoke-PackageStep {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Groups)
    $wanted = @($Groups | ForEach-Object { $Packages[$_] })
    # Installed with cargo on the existing machine, so only when missing.
    if ('dev' -in $Groups -and -not (Test-Command 'tree-sitter')) {
        $wanted += 'main/tree-sitter'
    }
    $missing = @(Get-MissingApps -Wanted $wanted -Installed (Get-InstalledApps))
    New-Result 'scoop apps' 'ok' ('{0} of {1} already installed' -f ($wanted.Count - $missing.Count), $wanted.Count)
    if ($missing) {
        # Only touch the network when something is missing.
        if ($PSCmdlet.ShouldProcess('scoop and its buckets', 'update')) {
            Invoke-Scoop update | Out-Host
        }
        Install-ScoopApps -Apps $missing
    }
    if ('core' -in $Groups) {
        Install-SymbolsFont
    }
    if ('dev' -in $Groups) {
        Install-Rustup
        Test-MsvcTools
        Install-NodeLts
    }
}

# ------------------------------------------------------------ admin tasks

function Get-PendingAdminTasks([string[]]$Steps, $UacValue, [bool]$VcredistInstalled) {
    $tasks = @()
    if ('system' -in $Steps -and $UacValue -ne 0) { $tasks += 'uac' }
    if ('packages' -in $Steps -and -not $VcredistInstalled) { $tasks += 'vcredist' }
    $tasks
}

# Windows PowerShell 5.1 joins -ArgumentList without quoting, so the line is
# built by hand.
function Get-AdminArguments([string]$File, [string[]]$Tasks) {
    '-NoProfile -ExecutionPolicy Bypass -File "{0}" -AdminTasks {1}' -f $File, ($Tasks -join ',')
}

# Runs elevated: in the re-run, or inline when setup itself is elevated.
function Invoke-AdminTask([string[]]$Tasks) {
    foreach ($task in $Tasks) {
        if ($task -eq 'uac') {
            try {
                # Admins elevate without a prompt (the old install script's
                # behaviour, kept on purpose).
                Set-ItemProperty -LiteralPath $UacKey -Name ConsentPromptBehaviorAdmin -Value 0 -Type DWord -ErrorAction Stop
                New-Result 'uac prompts off' 'changed' 'ConsentPromptBehaviorAdmin = 0'
            }
            catch {
                New-Result 'uac prompts off' 'failed' $_.Exception.Message
            }
        }
        elseif ($task -eq 'vcredist') {
            try {
                if (-not (Test-Command 'git')) { Invoke-Scoop install main/git | Out-Host }
                if ('extras' -notin @(Invoke-Scoop bucket list | ForEach-Object { $_.Name })) {
                    Invoke-Scoop bucket add extras | Out-Host
                }
                # Its installer refuses to run without admin rights.
                Invoke-Scoop install extras/vcredist-aio | Out-Host
                if ('vcredist-aio' -in @(Get-InstalledApps)) {
                    New-Result 'app vcredist-aio' 'changed' 'installed'
                }
                else {
                    New-Result 'app vcredist-aio' 'failed' 'scoop install extras/vcredist-aio did not finish'
                }
            }
            catch {
                New-Result 'app vcredist-aio' 'failed' $_.Exception.Message
            }
        }
    }
}

function Invoke-AdminStep {
    [CmdletBinding(SupportsShouldProcess)]
    param([string[]]$Tasks, [string]$File)
    if (-not $Tasks) {
        return
    }
    # Checked before the elevated shortcut: a dry run from an admin shell
    # must not run the tasks either.
    if (-not $PSCmdlet.ShouldProcess(($Tasks -join ', '), 'run elevated')) {
        return $Tasks | ForEach-Object { New-Result "admin $_" 'would' 'needs one elevated run' }
    }
    if (Test-Admin) {
        return Invoke-AdminTask $Tasks
    }
    Remove-Item -LiteralPath $AdminResultFile -ErrorAction SilentlyContinue
    try {
        $process = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList (Get-AdminArguments $File $Tasks)
    }
    catch {
        return New-Result 'admin tasks' 'failed' "elevation declined or failed: $($_.Exception.Message)"
    }
    if (-not (Test-Path -LiteralPath $AdminResultFile)) {
        return New-Result 'admin tasks' 'failed' "the elevated run exited with $($process.ExitCode) and left no results"
    }
    # 5.1's ConvertFrom-Json emits a JSON array as one object; foreach
    # unrolls it.
    $items = Get-Content -LiteralPath $AdminResultFile -Raw | ConvertFrom-Json
    Remove-Item -LiteralPath $AdminResultFile
    foreach ($i in $items) {
        New-Result $i.Item $i.Status $i.Detail
    }
}

# ------------------------------------------------------------- bootstrap

# The repo root when this file runs from a clone; $null when it runs as a
# downloaded scriptblock ($PSScriptRoot is empty then).
function Get-RepoRoot([string]$ScriptRoot) {
    if ($ScriptRoot -and (Test-Path -LiteralPath (Join-Path $ScriptRoot '.config') -PathType Container)) {
        return $ScriptRoot
    }
    $null
}

function Get-CloneAction([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return 'clone'
    }
    if (Test-Path -LiteralPath (Join-Path $Path '.git')) {
        return 'reuse'
    }
    throw "$Path exists but is not a git clone; move it away or pass -Dir"
}

# scoop, git and a clone of the repo. Returns the clone's root, or $null
# when the run cannot go on (a dry run with nothing cloned yet, or a failure).
function Invoke-Bootstrap {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Path, [string]$Source, $Results)
    $Results.Add((Set-UserExecutionPolicy))
    $scoop = Initialize-Scoop
    $Results.Add($scoop)
    if ($scoop.Status -in 'failed', 'would') {
        return $null
    }
    if (-not (Test-Command 'git')) {
        if (-not $PSCmdlet.ShouldProcess('main/git', 'scoop install')) {
            $Results.Add((New-Result 'app git' 'would' 'scoop install main/git'))
            return $null
        }
        Invoke-Scoop install main/git | Out-Host
        if (-not (Test-Command 'git')) {
            $Results.Add((New-Result 'app git' 'failed' 'scoop install main/git did not finish'))
            return $null
        }
        $Results.Add((New-Result 'app git' 'changed' 'installed'))
    }
    try {
        $action = Get-CloneAction $Path
    }
    catch {
        $Results.Add((New-Result 'clone' 'failed' $_.Exception.Message))
        return $null
    }
    if ($action -eq 'reuse') {
        $Results.Add((New-Result 'clone' 'ok' "using the clone at $Path"))
    }
    elseif ($PSCmdlet.ShouldProcess($Path, "git clone $Source")) {
        git clone $Source $Path | Out-Host
        if ($LASTEXITCODE -ne 0) {
            $Results.Add((New-Result 'clone' 'failed' "git clone exited with $LASTEXITCODE"))
            return $null
        }
        $Results.Add((New-Result 'clone' 'changed' "cloned into $Path"))
    }
    else {
        $Results.Add((New-Result 'clone' 'would' "git clone $Source $Path"))
        return $null
    }
    $root = Get-RepoRoot $Path
    if (-not $root) {
        $Results.Add((New-Result 'clone' 'failed' "$Path has no .config folder; is it a clone of this repo?"))
    }
    $root
}

# ----------------------------------------------------------------- links

# New-Item resolves a link's -Value as a wildcard pattern in 5.1, so a
# target folder with [ ] in its name is "not found" unless escaped. -Path is
# taken literally and must not be escaped.
function New-Junction([string]$Path, [string]$To) {
    New-Item -ItemType Junction -Path $Path -Value ([WildcardPattern]::Escape($To)) -ErrorAction Stop | Out-Null
    # Read it back: a result says "changed" only for a link that is there.
    $made = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if ($made.LinkType -ne 'Junction' -or (Get-NormalizedPath @($made.Target)[0]) -ne (Get-NormalizedPath $To)) {
        throw "created $Path, but it does not point at $To"
    }
}

# Deletes a link, never what it points at. Remove-Item -Recurse on a
# junction can delete the target's contents in 5.1; these calls never recurse.
function Remove-Link($Item) {
    if ($Item.PSIsContainer) {
        [IO.Directory]::Delete($Item.FullName, $false)
    }
    else {
        [IO.File]::Delete($Item.FullName)
    }
}

# Point $Target at $Source with a junction (no admin needed), without ever
# deleting anything that isn't a link: an existing folder is renamed to
# <target>.bak-<timestamp>, and only its Carry files move into $Source.
function Set-ConfigLink {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target,
        [string[]]$Carry = @()
    )
    $item = "link $Name"
    try {
        if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
            throw "source folder missing: $Source"
        }
        $src = Get-NormalizedPath $Source
        $Target = Resolve-UserPath $Target
        $existing = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue

        if ($existing -and $existing.LinkType) {
            $current = @($existing.Target)[0]
            if ($current -and (Get-NormalizedPath $current) -eq $src) {
                return New-Result $item 'ok' $Target
            }
            if (-not $PSCmdlet.ShouldProcess($Target, "re-point link from '$current' to '$src'")) {
                return New-Result $item 'would' "re-point $Target -> $src"
            }
            Remove-Link $existing
            try {
                New-Junction $Target $src
            }
            catch {
                # Never leave the config unlinked: put the old link back.
                $why = $_.Exception.Message
                $restored = $false
                try { New-Junction $Target $current; $restored = $true } catch { }
                if ($restored) {
                    throw "could not link $Target -> $src ($why); the old link is back"
                }
                throw "could not link $Target -> $src ($why), and could not restore the old link to $current"
            }
            return New-Result $item 'changed' "re-pointed $Target -> $src (was $current)"
        }

        if ($existing) {
            if ($existing.PSIsContainer) {
                $clash = @($Carry | Where-Object {
                        (Test-Path -LiteralPath (Join-Path $existing.FullName $_)) -and
                        (Test-Path -LiteralPath (Join-Path $src $_))
                    })
                if ($clash) {
                    throw "both $Target and $src have $($clash -join ', '); merge them by hand, then re-run"
                }
            }
            $backup = '{0}.bak-{1}' -f $existing.FullName, (Get-Date -Format 'yyyyMMdd-HHmmss')
            if (-not $PSCmdlet.ShouldProcess($Target, "move to $backup and link to $src")) {
                return New-Result $item 'would' "back up $Target, then link -> $src"
            }
            # Rename first: if the folder is in use (Nushell holds its history
            # open) this fails with nothing changed yet.
            Rename-Item -LiteralPath $existing.FullName -NewName (Split-Path $backup -Leaf) -ErrorAction Stop
            $moved = @()
            try {
                foreach ($file in $Carry) {
                    $from = Join-Path $backup $file
                    if (Test-Path -LiteralPath $from) {
                        Move-Item -LiteralPath $from -Destination (Join-Path $src $file) -ErrorAction Stop
                        $moved += $file
                    }
                }
                New-Junction $Target $src
            }
            catch {
                # Undo, so a failure leaves the folder exactly as it was.
                $why = $_.Exception.Message
                $made = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
                if ($made -and $made.LinkType) { Remove-Link $made }
                foreach ($file in $moved) {
                    Move-Item -LiteralPath (Join-Path $src $file) -Destination (Join-Path $backup $file) -ErrorAction SilentlyContinue
                }
                Rename-Item -LiteralPath $backup -NewName (Split-Path $Target -Leaf) -ErrorAction SilentlyContinue
                if (Test-Path -LiteralPath $Target) {
                    throw "could not link $Target -> $src ($why); the folder was put back"
                }
                throw "could not link $Target -> $src ($why); the old folder is still at $backup"
            }
            return New-Result $item 'changed' "linked $Target -> $src; old contents in $backup"
        }

        if (-not $PSCmdlet.ShouldProcess($Target, "link to $src")) {
            return New-Result $item 'would' "link $Target -> $src"
        }
        $parent = Split-Path $Target -Parent
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -ErrorAction Stop | Out-Null
        }
        New-Junction $Target $src
        New-Result $item 'changed' "linked $Target -> $src"
    }
    catch {
        New-Result $item 'failed' $_.Exception.Message
    }
}

function Invoke-LinkStep([string]$RepoRoot) {
    foreach ($link in $Links) {
        $carry = if ($link.Carry) { $link.Carry } else { @() }
        Set-ConfigLink -Name $link.Name -Source (Join-Path $RepoRoot $link.Source) -Target $link.Target -Carry $carry
    }
}

# ------------------------------------------------------------------- main

function Write-Summary($Results) {
    $colors = @{ ok = 'DarkGray'; changed = 'Green'; would = 'Cyan'; failed = 'Red'; note = 'Yellow' }
    Write-Step 'summary'
    foreach ($r in $Results) {
        Write-Host ('  {0,-8} {1,-26} {2}' -f $r.Status, $r.Item, $r.Detail) -ForegroundColor $colors[$r.Status]
    }
    $count = { param($s) @($Results | Where-Object Status -eq $s).Count }
    Write-Host ''
    Write-Host ('{0} changed, {1} would change, {2} failed, {3} already fine' -f
        (& $count 'changed'), (& $count 'would'), (& $count 'failed'), (& $count 'ok'))
    if ($WhatIfPreference) {
        Write-Host 'Dry run: nothing was changed.' -ForegroundColor Cyan
    }
}

function Invoke-Setup {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    # Stock 5.1 may not offer TLS 1.2, which GitHub and get.scoop.sh require.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
    # 5.1's download progress bar slows Invoke-WebRequest to a crawl.
    $ProgressPreference = 'SilentlyContinue'
    $results = New-Object System.Collections.Generic.List[object]
    try {
        $stepList = ConvertTo-List $Steps
        Assert-Allowed 'step' $stepList $AllSteps
        $groupList = ConvertTo-List $Groups
        Assert-Allowed 'group' $groupList $AllGroups
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
    }

    $repoRoot = Get-RepoRoot $PSScriptRoot
    $self = $PSCommandPath
    # Bootstrap already reported the execution policy and scoop.
    $bootstrapped = -not $repoRoot
    if (-not $repoRoot) {
        # Resolved here, so ~ and relative paths mean the same thing to
        # Test-Path, git and .NET.
        $path = (Resolve-UserPath $Dir).TrimEnd('\')
        Write-Step "bootstrap: not running from a clone, using $path"
        $repoRoot = Invoke-Bootstrap -Path $path -Source $Repo -Results $results
        if (-not $repoRoot) {
            Write-Summary $results
            return
        }
        $self = Join-Path $repoRoot 'setup.ps1'
    }

    if ('system' -in $stepList) {
        Write-Step 'system'
        if (-not $bootstrapped) {
            $results.Add((Set-UserExecutionPolicy))
        }
        $results.Add((Set-NeverSleep))
    }
    if ('packages' -in $stepList -and -not $bootstrapped) {
        $results.Add((Initialize-Scoop))
    }

    # Admin-only work, in one elevated run, before packages: with UAC
    # prompts off first, nvm's own elevation later doesn't prompt either.
    $vcredist = ('packages' -in $stepList) -and (Test-Command 'scoop') -and ('vcredist-aio' -in @(Get-InstalledApps))
    $pending = @(Get-PendingAdminTasks -Steps $stepList -UacValue (Get-UacValue) -VcredistInstalled $vcredist)
    if ('system' -in $stepList -and 'uac' -notin $pending) {
        $results.Add((New-Result 'uac prompts off' 'ok'))
    }
    if ('packages' -in $stepList -and 'vcredist' -notin $pending) {
        $results.Add((New-Result 'app vcredist-aio' 'ok'))
    }
    foreach ($r in @(Invoke-AdminStep -Tasks $pending -File $self)) {
        $results.Add($r)
    }

    if ('packages' -in $stepList -and (Test-Command 'scoop')) {
        Write-Step "packages ($($groupList -join ', '))"
        foreach ($r in @(Invoke-PackageStep -Groups $groupList)) {
            $results.Add($r)
        }
    }
    if ('links' -in $stepList) {
        Write-Step 'links'
        foreach ($r in @(Invoke-LinkStep -RepoRoot $repoRoot)) {
            $results.Add($r)
        }
    }
    Write-Summary $results
}

# The elevated re-run: do the admin tasks, hand the results back through a
# file, and exit with a status. The only place this script exits.
function Invoke-ElevatedRun {
    $tasks = ConvertTo-List $AdminTasks
    Assert-Allowed 'admin task' $tasks $AllAdminTasks
    $results = @(Invoke-AdminTask $tasks)
    ConvertTo-Json -InputObject $results | Set-Content -LiteralPath $AdminResultFile
    [int][bool]@($results | Where-Object Status -eq 'failed').Count
}

# Dot-sourcing (the tests) loads the functions without running anything.
if ($MyInvocation.InvocationName -ne '.') {
    if ($AdminTasks) {
        exit (Invoke-ElevatedRun)
    }
    Invoke-Setup
}
