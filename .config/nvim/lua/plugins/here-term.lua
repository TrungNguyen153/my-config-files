return {
    "jaimecgomezz/here.term",
    enabled = not vim.g.vscode,
    config = function()
        vim.opt.hidden = true
        require('here-term').setup()
    end,
}