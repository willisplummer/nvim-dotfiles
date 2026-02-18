return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
					"tsx",
					"typescript",
					"javascript",
					"lua",
					"json",
					"html",
					"css",
					"markdown",
					"markdown_inline",
				},
				highlight = {
					enable = true, -- 🔧 turn this ON
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true, -- 🔧 also turn this ON
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						node_decremental = "grm",
						scope_incremental = "grc",
					},
				},
			})
		end,
	},
}
