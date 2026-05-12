# Sharing the Neovim config between WSL and the Windows host

**Status:** design approved (2026-05-12)
**Scope:** WSL + config-sharing only. Solidity / Solana / Anchor tooling is a follow-up spec.

## Problem

The author develops primarily in Rust, with Solidity and Solana work that requires Linux toolchains. They want WSL Ubuntu to become the daily-driver Neovim environment, with Neovide on Windows attaching to nvim inside WSL via `neovide --wsl`. The existing native Windows nvim install must stay functional as a fallback (offline / WSL down).

The hard part is `lazy-lock.json`: the same file cannot be a single source of truth across two OSes if each can independently run `:Lazy update`, even though its *contents* are platform-neutral git SHAs. The lockfile becomes operationally conflicting, not structurally conflicting.

Secondary issues the design must address:

- Where the config files physically live (filesystem locality affects nvim startup over the WSL/NTFS 9P boundary).
- A `vim.o.shell = 'nu'` setting that breaks every shell-out plugin in WSL Ubuntu (no `nu` on PATH by default).
- Verifying the existing clipboard, Mason, treesitter, and rustaceanvim plugins work in WSL without code changes.

## Constraints

- Native `nvim.exe` on Windows must keep working — fallback mode.
- WSL is the daily driver — startup, LSP, plugin updates must feel snappy.
- Lockfile updates from either side must not conflict with each other.
- Existing config layout (lazy.nvim, ~50 plugins, rustaceanvim, Mason, clipipe, neovide-aware settings) stays intact. Surgical changes only.

## Architecture

```
                          D:\Workspace\my-config-files\        (git repo, GitHub remote)
                            +-- .config\nvim\                  <-- the real config tree
                                  +-- init.lua
                                  +-- lua\settings\general.lua
                                  +-- lua\plugins\...
                                  +-- lazy-lock.windows.json   (NEW: committed)
                                  +-- lazy-lock.wsl.json       (NEW: committed)
                                  +-- queries\, stylua.toml, ...
                                          ^
                                          |
        +--------------------------------+--------------------------------+
        |                                                                 |
   Windows view                                                      WSL view
   C:\Users\OS\AppData\Local\nvim                              ~/.config/nvim
     (existing Junction)                                       (NEW symlink, sibling, not chain)
        |                                                                 |
        v                                                                 v
   nvim.exe / neovide.exe                                         nvim (Linux, ext4 $HOME)
   stdpath('data') -> %LOCALAPPDATA%\nvim-data                    stdpath('data') -> ~/.local/share/nvim
   stdpath('cache') -> %LOCALAPPDATA%\nvim-cache                  stdpath('cache') -> ~/.cache/nvim

   Fallback role                                                  Primary role
   "nvim.exe" launched from Terminal / Explorer                   "neovide --wsl --neovim-bin /usr/local/bin/nvim"
                                                                  launched from Windows; UI on Windows, process in WSL
```

**Invariant:** the config tree is *one* directory on disk. Both OSes see it via sibling symlinks. Per-OS state (`stdpath('data')`, `stdpath('cache')`, Mason binaries, treesitter parsers) already differs per OS by default — no work required there.

## Components

### 1. Filesystem topology

- **Windows (already correct):** `C:\Users\OS\AppData\Local\nvim` is a Junction to `D:\Workspace\my-config-files\.config\nvim`. No change.
- **WSL (new):** symlink `~/.config/nvim` → `/mnt/d/Workspace/my-config-files/.config/nvim`.
  - Sibling symlink, not a chain through the Windows Junction.
  - Accepts a ~100–200 ms cold-start penalty: nvim reads ~60 small Lua files over DrvFs/9P. Plugin data, Mason binaries, and treesitter parsers stay on ext4 in `$HOME`, so `:Lazy sync`, parser compilation, and Mason installs run at native speed.

### 2. Lockfile-per-OS

Both lockfiles are committed to git. `lazy.nvim`'s documented `lockfile` config option routes reads/writes to the right one based on `vim.fn.has('wsl')`.

Edit `init.lua`:

```lua
local is_wsl = vim.fn.has('wsl') == 1
local lock = is_wsl and 'lazy-lock.wsl.json' or 'lazy-lock.windows.json'

require('lazy').setup('plugins', {
    lockfile = vim.fn.stdpath('config') .. '/' .. lock,
    checker = { enabled = true, frequency = 7200 },
    rocks   = { enabled = false },
})
```

**Migration:** `git mv lazy-lock.json lazy-lock.windows.json` (the existing file was generated on Windows). First WSL launch will create `lazy-lock.wsl.json` automatically when `:Lazy sync` runs.

**Why this works:** `:Lazy update` writes to the configured lockfile; `:Lazy restore` reads from it. Each OS drives independent reproducibility off its own file. Fresh clones (new laptop, reinstall) are fully reproducible per OS.

### 3. Shell branching

Replace the existing `powershell_options` block in `lua/settings/general.lua` with:

```lua
local is_wsl = vim.fn.has('wsl') == 1
local is_win = vim.fn.has('win32') == 1

if is_win and not is_wsl then
    vim.opt.shell        = 'nu'
    vim.opt.shellcmdflag = '-c'
    vim.opt.shellquote   = ''
    vim.opt.shellxquote  = ''
    vim.opt.shellslash   = true
else
    vim.opt.shell        = 'bash'
    vim.opt.shellcmdflag = '-c'
end
```

All plugins that shell out (`toggleterm`, the custom rustaceanvim executor, `conform`, mason installers, snacks/telescope find-in-files via `rg`, `gitsigns`) read `vim.o.shell`. One switch covers all of them.

### 4. Neovide launch

Neovide stays on Windows. Launch with:

```pwsh
neovide --wsl --neovim-bin /usr/local/bin/nvim
```

The Neovide settings in `lua/settings/neovide.lua` (`vim.g.neovide_*`) apply over the embedded RPC — no changes needed.

### 5. Clipboard

`bkoropoff/clipipe` already in the plugin set with `download = true, build = true`. It will fetch/build a Linux binary on first WSL launch. No config change. If problems arise, fall back to the OSC52 path Neovide already provides (yanks reach the Windows clipboard via the GUI's clipboard integration).

### 6. WSL-side prerequisites (one-time, manual)

```bash
sudo apt update
sudo apt install -y build-essential git curl unzip ripgrep fd-find xclip

# nvim from upstream (apt's version is too old for vim.lsp.config / on_type_formatting used in lspconfig.lua)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Rust toolchain for rustaceanvim
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
rustup component add rust-src rust-analyzer rustfmt clippy
```

### 7. First-launch ritual in WSL

After the symlink is created and `neovide --wsl` connects the first time:

1. `:Lazy sync` — clones plugins to `~/.local/share/nvim/lazy/`, writes `lazy-lock.wsl.json`.
2. mason-tool-installer auto-installs codelldb, clangd, shfmt, stylua, taplo as Linux binaries under `~/.local/share/nvim/mason/`.
3. Treesitter parsers compile on demand (needs `gcc` from build-essential).
4. clipipe downloads its Linux binary on first clipboard use.
5. Commit `lazy-lock.wsl.json` to git.

## Data Flow

**Edit on Windows:**
nvim.exe (or any Windows editor) writes `D:\Workspace\my-config-files\.config\nvim\lua\foo.lua` → both OSes see the change immediately (same inode behind both symlinks).

**Edit from WSL:**
nvim writes `/mnt/d/Workspace/my-config-files/.config/nvim/lua/foo.lua` → Windows sees the change. (DrvFs writes are slower than ext4 but acceptable for human-paced editing.)

**Plugin update on WSL:**
`:Lazy update` → clones/pulls plugin repos to `~/.local/share/nvim/lazy/` (ext4) → writes new SHAs to `lazy-lock.wsl.json` in the shared tree → git commit/push from WSL.

**Plugin update on Windows:**
`:Lazy update` → writes to `%LOCALAPPDATA%\nvim-data\lazy\` → writes `lazy-lock.windows.json`. Independent of WSL.

## Error Handling / Edge Cases

- **WSL distro stopped / `/mnt/d` not mounted:** WSL nvim can't start. User falls back to native `nvim.exe` on Windows. By design.
- **Windows decides to "fix" line endings or perms on the shared tree:** Git tracks the files; recovery is `git checkout .` from either side. The repo's `.gitattributes` should ideally pin `* text=auto eol=lf` for Lua files — call out in implementation plan.
- **`lazy-lock.wsl.json` doesn't exist on first WSL launch:** lazy.nvim treats missing lockfile as "no pins" and resolves to latest; `:Lazy sync` then writes the file. Expected behavior.
- **User accidentally runs `:Lazy update` and pushes the wrong lockfile:** the per-OS dispatch in `init.lua` keys on `vim.fn.has('wsl')`, which cannot be wrong inside a running session. No cross-contamination possible.
- **Stale junction on Windows (e.g., D: drive disconnected):** nvim.exe fails to start. Standard Windows behavior; not specific to this design.
- **`nvim --headless` in CI / scripts:** the shell branch still kicks in via `has('wsl')` / `has('win32')`. Both work standalone.

## Testing / Verification

Definition of done:

- [ ] `~/.config/nvim` symlink resolves to the real folder when checked via `readlink -f`.
- [ ] `nvim --headless +qa` cold-start in WSL completes in <1s with no error output.
- [ ] `:checkhealth lazy mason` clean on both OSes.
- [ ] `:RustLsp runnables` shows entries on a Cargo project under WSL.
- [ ] Editing a file from WSL nvim, saving, then `git status` on Windows shows the change (proves shared real folder).
- [ ] `:Lazy update` in WSL modifies only `lazy-lock.wsl.json`; `:Lazy update` on Windows modifies only `lazy-lock.windows.json`.
- [ ] Yanking a line in WSL nvim pastes correctly in a Windows app (clipipe round-trip).
- [ ] `nvim.exe` on Windows still launches and `:Lazy sync` works (fallback role preserved).

## Out of scope

- Solidity LSP (`solidity_ls` / `solang`), `forge fmt`, Solidity treesitter parser.
- Solana CLI, `anchor`, `anchor-lang` LSP, BPF Rust target.
- Migrating from clipipe to a different clipboard provider.
- Cloning the config repo inside WSL as a second working copy (current design uses a single shared real folder via `/mnt/d`).

These belong in a separate spec once the WSL+config-sharing change is verified working.
