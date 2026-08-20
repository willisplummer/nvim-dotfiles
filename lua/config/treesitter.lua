-- Treesitter highlighting for every filetype that has a parser installed.
--
-- This used to name eight filetypes explicitly, which meant python, nix, zig,
-- yaml, bash, go and friends silently fell back to regex syntax -- and, since
-- Neovim's `gc` resolves 'commentstring' through the syntax tree, lost
-- context-aware commenting too. Parsers come from Nix
-- (`nvim-treesitter.withAllGrammars`), so "has a parser" is the only condition
-- worth checking, and `vim.treesitter.start` already errors harmlessly when
-- there is none.
vim.api.nvim_create_autocmd("FileType", {
	desc = "Start treesitter highlighting",
	callback = function(args)
		if not pcall(vim.treesitter.start, args.buf) then
			return
		end

		-- Indentation is opt-in per filetype rather than automatic: nvim-treesitter's
		-- indentexpr is an improvement for these, but noticeably worse than the
		-- bundled indent scripts for others (python especially).
		local ts_indent = {
			css = true,
			html = true,
			javascript = true,
			javascriptreact = true,
			json = true,
			lua = true,
			markdown = true,
			typescript = true,
			typescriptreact = true,
		}

		if ts_indent[vim.bo[args.buf].filetype] then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
