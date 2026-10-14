-- auto complete, versions and actions for Cargo.toml
return {
    'Saecki/crates.nvim',
    enabled = not vim.g.vscode,
    event = 'BufRead Cargo.toml',
    opts = {
        lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
        },
        completion = {
            crates = {
                enabled = true,
            },
        },
    },
}
