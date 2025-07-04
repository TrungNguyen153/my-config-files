# If cant run script, run bellow command first on powershell
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Util functions
function Write-Start {
    param ($msg)
    Write-Host (">> " + $msg) -ForegroundColor Green
}

function Write-Done { Write-Host "DONE" -ForegroundColor Blue; Write-Host }

function Is-Administrator  
{  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

# Start
Start-Process -Wait powershell -verb runas -ArgumentList "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"

Write-Start -msg "Turn off sleep windows"
    Start-Process -Wait powercfg -ArgumentList "-change -monitor-timeout-ac 0"
    Start-Process -Wait powercfg -ArgumentList "-change -monitor-timeout-dc 0"
    Start-Process -Wait powercfg -ArgumentList "-change -disk-timeout-ac 0"
    Start-Process -Wait powercfg -ArgumentList "-change -disk-timeout-dc 0"
    Start-Process -Wait powercfg -ArgumentList "-change -standby-timeout-ac 0"
    Start-Process -Wait powercfg -ArgumentList "-change -standby-timeout-dc 0"
    Start-Process -Wait powercfg -ArgumentList "-change -hibernate-timeout-ac 0"
    Start-Process -Wait powercfg -ArgumentList "-change -hibernate-timeout-dc 0"
Write-Done

Write-Start -msg "Installing Scoop..."
if (Get-Command scoop -ErrorAction SilentlyContinue)
{
    Write-Warning "Scoop already installed"
}
else {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    if (Is-Administrator)
    {
        iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    }
    else 
    {
        irm get.scoop.sh | iex
    }
}
Write-Done

Write-Start -msg "Initializing Scoop..."
    scoop install git
    scoop bucket add extras
    scoop bucket add java
    scoop bucket add nerd-fonts
    scoop bucket add versions
    scoop bucket add sysinternals
    scoop bucket add main
    scoop update
Write-Done

Write-Start -msg "Installing Scoop's packages"
    scoop install 7zip
    scoop install extras/googlechrome
    scoop install extras/notepadplusplus
    # runtime
    Start-Process -Wait powershell -Verb runas -ArgumentList "scoop install vcredist-aio"
Write-Done

Write-Start -msg "Install Scoop's package for dev"
    scoop install main/ripgrep
    scoop install main/fd
    scoop install main/sed
    scoop install main/nvm
    scoop install main/clangd
    scoop install java/corretto19-jdk
    scoop install extras/fork
    scoop install main/gcc
    scoop install main/llvm
    scoop install main/make
    scoop install main/neovim
    scoop install sysinternals/process-explorer
    scoop install extras/wezterm
    scoop install extras/vscode
    scoop install extras/putty
    scoop install extras/winscp
    scoop install extras/dnspyex
    scoop install extras/debugviewpp
    scoop install versions/python311
    scoop install extras/skype
    scoop install nerd-fonts/RobotoMono-NF-Propo
    scoop install cmake
    scoop install sysinternals/tcpview
    # scoop install zoxide
Write-Done

Write-Start -msg "Install Nushell"
    winget install nushell
Write-Done

Read-Host