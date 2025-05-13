return {
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
				end,
			},
		},
		config = function(_, opts)
			-- Set this BEFORE require('ts_context_commentstring')
			vim.g.skip_ts_context_commentstring_module = true

			-- Setup ts-context-commentstring with default options
			require("ts_context_commentstring").setup({})

			-- Setup mini.comment
			require("mini.comment").setup(opts)
		end,
	},
}
