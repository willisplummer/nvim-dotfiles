-- tokyonight
return {
	"folke/tokyonight.nvim",
	-- lazy = true,
	opts = {
		style = "storm",
		transparent = true,
		styles = { functions = {} },
	},
	priority = 1000, -- Load this first
	config = function(_, opts)
		-- if you define config you have to tell lazy where to put the opts
		-- https://www.reddit.com/r/neovim/comments/1etgpj1/comment/lideg43
		require("tokyonight").setup(opts)
		vim.cmd([[colorscheme tokyonight]])
	end,
}
