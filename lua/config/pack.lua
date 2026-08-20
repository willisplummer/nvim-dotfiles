-- Plugin management with `vim.pack` (Neovim 0.12+), replacing lazy.nvim.
--
-- Differences worth knowing:
--   * There is no lazy loading. Everything is added at startup -- the plugin
--     set is small enough that the loading machinery cost more than it saved.
--   * Revisions live in `nvim-pack-lock.json` (tracked in git, written by
--     `vim.pack`, never edited by hand). Specs only set `version` when we want
--     to follow something other than the repo's default branch.
--   * 'packpath' is left alone. lazy.nvim reset it, which silently dropped the
--     Nix-provided nvim-treesitter and its grammars (site/pack/hm/start).
--   * Optional plugins are gated on env vars from `.env` (see `.env.example`);
--     the gate is applied to both the spec and its config module here, so it
--     lives in exactly one place.

local function gh(repo)
	return "https://github.com/" .. repo
end

local function enabled(var)
	return os.getenv(var) == "true"
end

-- Plugins to install. Dependencies are listed before the plugins that use them.
local specs = {
	-- Colorscheme first, so anything reading highlight groups sees the theme.
	gh("folke/tokyonight.nvim"),

	-- Icon provider. mini.icons mocks nvim-web-devicons (see plugins/icons.lua),
	-- so the real devicons package is not installed.
	gh("echasnovski/mini.icons"),

	-- Editing.
	{ src = gh("kylechui/nvim-surround"), version = vim.version.range("*") },
	gh("JoosepAlviste/nvim-ts-context-commentstring"),
	gh("echasnovski/mini.comment"),
	gh("nmac427/guess-indent.nvim"),
	gh("stevearc/conform.nvim"),

	-- Navigation and UI.
	gh("ibhagwan/fzf-lua"),
	gh("cbochs/grapple.nvim"),
	gh("stevearc/oil.nvim"),
	gh("christoomey/vim-tmux-navigator"),
	gh("jiaoshijie/undotree"),
	gh("folke/which-key.nvim"),

	-- LSP and completion.
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/nvim-cmp"),
	gh("neovim/nvim-lspconfig"),
}

-- Config modules, required in this order after everything is on 'runtimepath'.
local modules = {
	"plugins.colorscheme",
	"plugins.icons",
	"plugins.surround",
	"plugins.comment",
	"plugins.format",
	"plugins.fzf-lua",
	"plugins.harpoon",
	"plugins.oil",
	"plugins.undotree",
	"plugins.which-key",
	"plugins.cmp",
	"plugins.lsp",
}

if enabled("ENABLE_MASON") then
	vim.list_extend(specs, {
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
	})
	table.insert(modules, "plugins.mason")
end

if enabled("ENABLE_DEBUGGER") then
	vim.list_extend(specs, {
		gh("nvim-neotest/nvim-nio"),
		gh("mfussenegger/nvim-dap"),
		gh("rcarriga/nvim-dap-ui"),
		gh("theHamsta/nvim-dap-virtual-text"),
	})
	table.insert(modules, "plugins.debugger")
end

-- `confirm = false` matches how lazy.nvim behaved: the specs above are the
-- declaration, so there is nothing to agree to on a fresh checkout.
vim.pack.add(specs, { confirm = false })

-- Isolate config failures the way lazy.nvim did, so one broken module does not
-- take down the rest of the config.
for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		vim.notify(("Failed to load %s:\n%s"):format(module, err), vim.log.levels.ERROR)
	end
end

-- Stand-ins for `:Lazy`.
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Fetch plugin updates and open the confirmation buffer" })

vim.api.nvim_create_user_command("PackStatus", function()
	vim.pack.update(nil, { offline = true })
end, { desc = "Review installed plugins without fetching" })

vim.api.nvim_create_user_command("PackClean", function()
	local unused = vim.iter(vim.pack.get())
		:filter(function(plugin)
			return not plugin.active
		end)
		:map(function(plugin)
			return plugin.spec.name
		end)
		:totable()

	if #unused == 0 then
		vim.notify("No unused plugins on disk", vim.log.levels.INFO)
		return
	end

	vim.pack.del(unused)
end, { desc = "Delete plugins that are on disk but no longer in the spec list" })
