
-- Some option can find here (another type lsp but type analysis work)
-- https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance
local opt = {
	settings = {
		python = {
			analysis = {
        -- Default
        -- autoSearchPaths = true,
        --   diagnosticMode = "workspace",
        --   useLibraryCodeForTypes = true,
				-- useLibraryCodeForTypes = false,
        typeCheckingMode = "off",
        diagnosticMode = "openFilesOnly",
			},
		},
	},
}


return opt
