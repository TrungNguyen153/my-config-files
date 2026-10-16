<#
.SYNOPSIS
    Adds a folder to herdr as a workspace, for Explorer's "Add to herdr".
    herdr saves its workspaces, so the folder stays across server restarts.

.DESCRIPTION
    A folder that already has a pane in it is focused instead of added
    twice. The API does not start the server, so this starts it headless
    first when it is not running. A notification says what happened.
#>
param(
    [Parameter(Mandatory)][string]$Path,
    # A named herdr session instead of the default one.
    [string]$Session
)

$s = if ($Session) { @('--session', $Session) } else { @() }
function Test-Server { herdr @s pane list *> $null; $LASTEXITCODE -eq 0 }

$dir = (Resolve-Path -LiteralPath $Path).ProviderPath.TrimEnd('\')
$name = Split-Path $dir -Leaf
if (-not $name) { $name = $dir }

if (-not (Test-Server)) {
    # An empty session starts with a workspace here instead of in home.
    $env:HERDR_STARTUP_CWD = $dir
    Start-Process herdr -ArgumentList ($s + 'server') -WorkingDirectory $dir -WindowStyle Hidden
    foreach ($i in 1..40) {
        Start-Sleep -Milliseconds 250
        if (Test-Server) { break }
    }
    if (-not (Test-Server)) { throw 'herdr server did not start' }
}

$hit = (herdr @s pane list | ConvertFrom-Json).result.panes |
    Where-Object { $_.cwd.TrimEnd('\') -eq $dir } | Select-Object -First 1
if ($hit) {
    herdr @s workspace focus $hit.workspace_id | Out-Null
    herdr @s notification show "$name is already in herdr" --body $dir | Out-Null
}
else {
    herdr @s workspace create --cwd $dir --focus | Out-Null
    herdr @s notification show "Added $name to herdr" --body $dir --sound done | Out-Null
}
