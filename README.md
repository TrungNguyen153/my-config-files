# my-config-files

Windows setup for Neovim, Neovide, WezTerm and Nushell, plus `setup.ps1`,
one script that installs the tools and links the configs.

## New machine

In PowerShell. It installs scoop and git, clones this repo to
`~\Desktop\Workspace\my-config-files`, then runs the setup from the clone:

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; & ([scriptblock]::Create((irm https://raw.githubusercontent.com/TrungNguyen153/my-config-files/master/setup.ps1)))
```

Arguments go after the last `)`, e.g. `-Dir D:\Workspace\my-config-files` to
clone elsewhere. `-WhatIf` works too, but on a bare machine it stops after
reporting what it would install and clone: there is nothing to preview the
later steps from yet.

## Existing clone

```powershell
.\setup.ps1                  # everything
.\setup.ps1 -WhatIf          # dry run: report, change nothing
.\setup.ps1 -Steps links     # only some steps: system, packages, links
.\setup.ps1 -Groups core     # only some packages: core, dev, apps
```

If scripts are blocked: `powershell -ExecutionPolicy Bypass -File .\setup.ps1`.
It is safe to re-run: finished items are skipped, and the summary at the end
lists what changed and what failed.

## What it does

- **system**
  - Sets the CurrentUser execution policy to RemoteSigned, which scoop needs.
  - **Turns UAC prompts off for administrators.**
  - **Sets screen, disk, sleep and hibernate timeouts to never, on AC and on
    battery.**
- **packages**: scoop apps in three groups, then a few things scoop doesn't
  carry. Nothing is ever uninstalled.
  - core: what the configs here need.
  - dev: toolchains.
  - apps: everyday programs.
  - Outside scoop: the Noto Sans Symbols 2 font (WezTerm's fallback), rustup
    with nightly rustfmt, and node LTS through nvm.
  - vcredist-aio needs admin rights, so it installs in a single elevated run.
  - Rust also needs Visual Studio's C++ build tools. The summary warns when
    they are missing.
- **links**: junctions from where each program looks for its config to the
  folders under `.config\`.
  - Targets: `%LOCALAPPDATA%\nvim`, `~\.config\wezterm`, `%APPDATA%\nushell`
    and `%APPDATA%\neovide`.
  - An existing folder is renamed to `<name>.bak-<timestamp>`, never deleted.
  - Nushell's history moves into the repo folder, where .gitignore keeps it
    out of git.

Nushell's live history therefore sits inside this working tree, so don't run
`git clean -x` here.
