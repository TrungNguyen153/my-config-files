return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = 'VeryLazy',
		build = ":TSUpdate",
		config = require("setup.treesitter").setup,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects", -- adds treesitter based text objects
			{ "nvim-treesitter/playground", enabled = false }, -- TS PLayground for creating queries
			"nvim-treesitter/nvim-treesitter-context", -- shows context of offscreen block in a float
			"windwp/nvim-ts-autotag"
		},
	}, -- enhancements in highlighting and virtual text
}
