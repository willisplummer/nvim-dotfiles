vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"typescriptreact",
		"typescript",
		"javascript",
		"lua",
		"json",
		"html",
		"css",
		"markdown",
	},
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
