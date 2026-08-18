-- Gated on ENABLE_MASON; the spec and this module are wired up in config.pack.
require("mason").setup()

require("mason-lspconfig").setup({
	-- NOTE: consider vtsls instead of ts_ls
	ensure_installed = { "ts_ls", "eslint", "lua_ls", "biome", "stylelint_lsp" },
	-- mason-lspconfig v2 removed `handlers` and `automatic_installation`, and
	-- silently ignores unknown keys. `automatic_enable` is the replacement for
	-- the old handler that called `vim.lsp.enable()` per installed server, so
	-- the net behaviour is unchanged. The hand-written `vim.lsp.config.<name>`
	-- tables in plugins/lsp.lua still apply -- they merge over nvim-lspconfig's
	-- defaults, and `vim.lsp.enable()` is idempotent.
	automatic_enable = true,
})
