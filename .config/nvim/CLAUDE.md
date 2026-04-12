# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal Neovim configuration for polyglot development on Windows (NuShell as default shell). Runs on lazy.nvim plugin manager with ~60 plugins.

## Architecture

**Load order** (`init.lua`):
1. Bootstrap lazy.nvim
2. `utils.custom_fold` - custom fold text rendering
3. `settings.general` - editor options (leader=Space, localleader=`;`, 4-space tabs, treesitter folds, ripgrep for grep)
4. `settings.gui` - terminal colors, relative line numbers
5. `settings.neovide` - Neovide GUI settings (padding, animations, transparency)
6. `settings.unception` - prevent nested Neovim instances
7. `utils.keymaps` - core keybindings
8. `lazy.setup('plugins')` - all plugin specs from `lua/plugins/`
9. `utils.clipboard` - OS clipboard integration
10. `utils.autocommands` - autocmds (folds, LSP, CodeCompanion events)

**Key directories:**
- `lua/plugins/` - one file per plugin (or plugin group), auto-loaded by lazy.nvim
- `lua/settings/` - core vim options, separate from plugin config
- `lua/utils/` - shared helpers: keymaps, LSP on_attach/capabilities, autocommands, custom fold
- `lua/ai/cc/` - CodeCompanion extensions: slash command prompts (`prompts/`), custom tools (`tools/`), utilities

## Formatting and Linting

- **Lua**: `stylua` with config at `stylua.toml` (spaces, auto-prefer single quotes)
- **Format on save**: via `conform.nvim` (`lua/plugins/conform.lua`). Toggle per-buffer with `<leader>lc`
- Formatters by filetype: stylua (lua), prettier (js/ts/css/html/json/yaml), black (python), shfmt (sh), sqlfluff (sql), markdownlint (md)

When editing Lua files in this config, follow the existing style: single quotes, 4-space indentation, spaces for indent.

## LSP Setup

LSP servers are configured in `lua/plugins/lspconfig.lua`. All servers use shared `on_attach` and `capabilities` from `lua/utils/lsp.lua`.

- `on_attach` enables inlay hints and code lens when supported
- `capabilities` merges blink.cmp completions with UTF-16 offset encoding

Rust LSP is handled separately by `rustaceanvim` (`lua/plugins/rustacean.lua`), not lspconfig.

## Completion

Uses `blink.cmp` (not nvim-cmp). Config in `lua/plugins/cmp.lua`.

## AI Integration (CodeCompanion)

Config in `lua/plugins/code_companion.lua`. Uses Claude Code ACP adapter (opus model, plan mode).

- **Slash commands** are markdown files in `lua/ai/cc/prompts/` (review, refactor, doc, optimize, test_this, fix_diagnostics)
- **Custom tools** in `lua/ai/cc/tools/` (date calculator, calendar scheduler)
- **Tool groups**: `@{rust_dev}` (editing specialist), `@{reviewer}` (read-only)
- **Workflows**: Edit-Test Loop, Review-Fix-Test chain
- **Extensions**: history, spinners, UI (codecompanion-history.nvim, codecompanion-spinners.nvim, codecompanion-ui.nvim)

## Key Conventions

- Plugin specs return a table (or list of tables) from each file in `lua/plugins/`
- Keymaps use `<leader>` (Space) for most actions, `<localleader>` (`;`) for file-local actions
- AI keymaps: `<leader>a*` prefix (aa=chat, af=focus, at=toggle, ah=history, as=save, am=summary)
- LSP keymaps: `<leader>l*` prefix + standard gd/gr/gi/gt
- Git keymaps: `<leader>g*` prefix (via snacks.nvim picker)
- Rust-specific: `<leader>r*` prefix (via rustaceanvim)
