return {
	"MeanderingProgrammer/render-markdown.nvim",
	-- nvim-treesitter is provided by Nix (programs.neovim.plugins, main branch
	-- with precompiled grammars), so it is intentionally NOT a lazy dependency.
	dependencies = { "echasnovski/mini.icons" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
} 