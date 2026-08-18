-- Set this before requiring `ts_context_commentstring`.
vim.g.skip_ts_context_commentstring_module = true

require("ts_context_commentstring").setup({})

require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})
