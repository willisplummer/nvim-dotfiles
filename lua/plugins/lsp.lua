-- Reserve a space in the gutter
vim.opt.signcolumn = "yes"
-- Don't show parse errors in a separate window
vim.g.zig_fmt_parse_errors = 0
-- Disable format-on-save from `ziglang/zig.vim`
vim.g.zig_fmt_autosave = 0

-- Add cmp_nvim_lsp capabilities settings to default config
-- This should be executed before you configure any language server
local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)

-- LspAttach is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set("n", "<Leader>d", ":lua vim.diagnostic.open_float()<CR>", opts)
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
		vim.keymap.set("n", "<leader>ef", "<cmd>EslintFixAll<cr>", opts)
		vim.keymap.set("n", "<leader>lf", "<cmd>LintFix<cr>", opts)
	end,
})

-- Setup language servers using the new vim.lsp.config API
vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
	capabilities = capabilities,
	settings = {
		python = {
			pythonPath = "/home/dev/patreon_py/venv/bin/python",
		},
	},
}

vim.lsp.config.pylsp = {
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_markers = { "requirements.txt", ".git" },
	capabilities = capabilities,
	settings = {
		pylsp = {
			configurationSources = { "mypy" },
			plugins = {
				black = { enabled = true },
				rope = { enabled = true },
				ruff = { enabled = true },
				pylsp_mypy = {
					enabled = false,
					live_mode = false,
					dmypy = true,
					overrides = {
						"--show-traceback",
						"--use-fine-grained-cache",
					},
				},
				pyls_isort = { enabled = true },
				pyflakes = { enabled = false },
				pycodestyle = { enabled = false },
				mccabe = { enabled = false },
			},
		},
	},
	flags = {
		debounce_text_changes = 200,
	},
}

vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
	capabilities = capabilities,
}

-- `stylelint-lsp` comes from nix (~/nix/nvim.nix) and loads the *project's*
-- stylelint out of node_modules, so prf's plugins (studio token validation,
-- alphabetical property order) report here too.
--
-- Note on the missing `filetypes`/`root_markers`: `vim.lsp.config` deep-merges
-- our table over nvim-lspconfig's `lsp/<name>.lua`, and deep-merging *lists*
-- happens index by index -- `{ "css", "scss" }` over lspconfig's six filetypes
-- left a mangled list rather than replacing it. lspconfig's defaults are what
-- we want anyway: it only starts a server in projects that have its config file
-- (`.stylelintrc.js` for prf), which keeps it quiet everywhere else.
vim.lsp.config.stylelint_lsp = {
	cmd = { "stylelint-lsp", "--stdio" },
	capabilities = capabilities,
	settings = {
		stylelintplus = {
			autoFixOnFormat = true,
			autoFixOnSave = false,
		},
	},
}

-- Biome owns formatting, import ordering (`assist/source/organizeImports`) and
-- roughly half of prf's lint rules; oxlint (below) owns the other half.
--
-- Everything but `capabilities` is deliberately left to nvim-lspconfig:
--   * its `cmd` prefers `<root>/node_modules/.bin/biome`, so the editor runs the
--     version the repo pins (2.5.8 in prf) instead of whatever nix installed
--   * its `root_dir` knows about `biome.jsonc` and monorepos; our old
--     `root_markers = { "biome.json", ".git" }` only matched prf via `.git`
vim.lsp.config.biome = {
	capabilities = capabilities,
}

-- oxlint is prf's ESLint replacement, and the reason a chunk of lint errors were
-- invisible in here: nothing was running it. lspconfig's `cmd` prefers
-- `<root>/node_modules/.bin/oxlint --lsp`, matching the version CI and
-- pre-commit use.
vim.lsp.config.oxlint = {
	capabilities = capabilities,
	settings = {
		-- Type-aware rules shell out to tsgolint and cost ~2s per run on prf, so
		-- lint on write instead of on every keystroke. Flip to "onType" if you
		-- would rather have the latency than the delay.
		run = "onSave",
		typeAware = true,
		-- Matches `oxc.fixKind` in prf's .vscode/settings.json.
		fixKind = "all",
	},
	on_init = function(client)
		local settings = vim.deepcopy(client.settings or {})

		-- prf runs oxlint twice, with two configs: native rules (.oxlintrc.jsonc,
		-- which oxlint finds on its own) and JS-plugin rules
		-- (.oxlintrc.js-plugins.jsonc -- local-rules, testing-library, storybook,
		-- css-modules). A language server only reads one config, so the repo ships
		-- `.oxlintrc.editor.jsonc`, which extends both. Without pointing at it we
		-- silently lose every `local-rules/*` and `css-modules/*` error.
		local editor_config = ".oxlintrc.editor.jsonc"
		if client.root_dir and vim.uv.fs_stat(vim.fs.joinpath(client.root_dir, editor_config)) then
			settings.configPath = editor_config
		end

		-- Why this is sent by hand rather than left to `settings` alone: oxlint
		-- 1.78 only reads its options out of `workspace/didChangeConfiguration`,
		-- and the notification nvim sends automatically (from `settings`, just
		-- before this callback) cannot carry a per-project `configPath`. Sending
		-- the complete set here overrides that one.
		client:notify("workspace/didChangeConfiguration", { settings = settings })
	end,
}

-- prf has finished deleting its eslint config, so this now only starts in the
-- repos that still have one. The old `root_markers` matched any `package.json`,
-- which meant an eslint server attaching to prf files with nothing to lint.
vim.lsp.config.eslint = {
	capabilities = capabilities,
}

vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.ccls = {
	cmd = { "ccls" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { "compile_commands.json", ".ccls", ".git" },
	capabilities = capabilities,
}

vim.lsp.config.zls = {
	cmd = { "zls" },
	filetypes = { "zig", "zir" },
	root_markers = { "zls.json", "build.zig", ".git" },
	capabilities = capabilities,
	settings = {
		zls = {
			enable_build_on_save = true,
			build_on_save_step = "check",
		},
	},
}

-- Enable the configured LSP servers
vim.lsp.enable("pyright")
vim.lsp.enable("pylsp")
vim.lsp.enable("lua_ls")
vim.lsp.enable("stylelint_lsp")
vim.lsp.enable("biome")
vim.lsp.enable("oxlint")
vim.lsp.enable("eslint")
vim.lsp.enable("ts_ls")
vim.lsp.enable("ccls")
vim.lsp.enable("zls")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	virtual_text = {
		prefix = "●",
		-- biome, oxlint and ts_ls all report on the same buffer in prf; without
		-- this there is no way to tell which one is complaining.
		source = "if_many",
	},
	float = {
		source = true,
		border = "rounded",
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

-- `:LintFix` applies every autofix the linters offer, in the same order as prf's
-- pre-commit hook: biome's safe lint fixes plus import sorting, then oxlint's.
-- Pure formatting is conform's job (`<leader>f` / `:Format`), and import sorting
-- also happens there on save -- this command is for the rest.
local function apply_biome_fixes(bufnr)
	local applied = false

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "biome" })) do
		local params = {
			textDocument = vim.lsp.util.make_text_document_params(bufnr),
			-- Source actions apply to the whole document; the range is ignored.
			range = {
				start = { line = 0, character = 0 },
				["end"] = { line = 0, character = 0 },
			},
			context = {
				diagnostics = {},
				only = { "source.fixAll.biome", "source.organizeImports.biome" },
			},
		}

		local response = client:request_sync("textDocument/codeAction", params, 5000, bufnr)
		for _, action in ipairs(response and response.result or {}) do
			if action.edit then
				vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
				applied = true
			end
		end
	end

	return applied
end

local function apply_oxlint_fixes(bufnr)
	local applied = false

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "oxlint" })) do
		client:exec_cmd({
			title = "Apply oxlint automatic fixes",
			command = "oxc.fixAll",
			arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
		})
		applied = true
	end

	return applied
end

vim.api.nvim_create_user_command("LintFix", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local fixed_biome = apply_biome_fixes(bufnr)
	local fixed_oxlint = apply_oxlint_fixes(bufnr)

	if not fixed_biome and not fixed_oxlint then
		vim.notify("LintFix: no biome or oxlint client attached to this buffer", vim.log.levels.WARN)
	end
end, {
	desc = "Apply biome + oxlint autofixes to the current buffer",
})
