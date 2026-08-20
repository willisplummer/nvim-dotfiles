local conform = require("conform")

-- In a biome project (prf), `biome format` handles layout and
-- `biome check --write` with only assists enabled handles import ordering --
-- biome reports unsorted imports as `assist/source/organizeImports`, which the
-- plain formatter does not touch. Two passes rather than `biome check --write`
-- so that saving never applies lint fixes (deleting an import you are halfway
-- through typing, say); `:LintFix` is the opt-in for those.
-- Anything else falls back to prettier.
-- conform calls `command` as `(self, ctx)`, not with a bufnr. The project's own
-- ruff is preferred over anything on $PATH; see config/venv.lua for why.
local function ruff_command(_, ctx)
	return require("config.venv").bin("ruff", ctx.buf)
end

local function js_formatters(bufnr)
	if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
		return { "biome", "biome-organize-imports" }
	end

	return { "prettierd", "prettier", stop_after_first = true }
end

conform.setup({
	-- Map of filetype to formatters
	default_format_opts = {
		timeout_ms = 5000,
		async = false,
		quiet = false,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		-- Use a sub-list to run only the first available formatter
		javascript = js_formatters,
		typescript = js_formatters,
		javascriptreact = js_formatters,
		typescriptreact = js_formatters,
		-- `stylelint --fix` first (it owns property ordering), then biome for
		-- layout. This used to read `styleint`, which conform silently skipped.
		css = { "stylelint", "biome" },
		-- ppy switched to ruff: pre-commit runs `ruff-check --fix` then
		-- `ruff-format`, and import ordering is ruff's own isort (I001 plus
		-- `[tool.ruff.lint.isort]`). black and isort are still in
		-- dev-requirements.in but have no pre-commit hook -- formatting with them
		-- here produced diffs CI would undo.
		python = { "ruff_organize_imports", "ruff_format" },
		nix = { "nixfmt", stop_after_first = true },
		zig = { "zigfmt", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		-- Use the "*" filetype to run formatters on all filetypes.
		-- ["*"] = { "codespell" },
		-- Use the "_" filetype to run formatters on filetypes that don't
		-- have other formatters configured.
		["_"] = { "trim_whitespace" },
	},
	formatters = {
		-- `command` is resolved per buffer, so opening two repos in one session
		-- gets each one its own pinned ruff.
		ruff_format = { command = ruff_command },
		ruff_organize_imports = { command = ruff_command },
		ruff_fix = { command = ruff_command },
	},
	-- If this is set, Conform will run the formatter on save.
	-- It will pass the table to conform.format().
	-- This can also be a function that returns the table.
	format_on_save = function(bufnr)
		-- Disable with a global or buffer-local variable
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 5000, lsp_format = "fallback" }
	end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Disable autoformat-on-save",
	bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = "Re-enable autoformat-on-save",
})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil

	-- `:'<,'>Format` formats just the selection.
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end

	conform.format({ async = true, lsp_format = "fallback", range = range })
end, {
	desc = "Format the current buffer (or selection)",
	range = true,
})

vim.keymap.set("n", "<leader>f", function()
	conform.format({ async = true })
end, { desc = "Format buffer" })

require("guess-indent").setup({})
