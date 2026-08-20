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

		-- Only what Neovim 0.12 does not already provide. The defaults are
		-- `grn` rename, `gra` code action, `grr` references, `gri` implementation,
		-- `grt` type definition, `gO` document symbols, `<C-s>` signature help in
		-- insert mode, and `<C-w>d` for the diagnostic float -- plus buffer-local
		-- `K` hover, `gq` format (via 'formatexpr') and `<C-]>` (via 'tagfunc').
		--
		-- Deliberately not remapped:
		--   * `K` -- the default is skipped when a custom `K` keymap exists, so the
		--     old mapping was suppressing the default in order to do the same thing.
		--   * `gr` -- it shadowed the whole `gr*` family above, making every one of
		--     them wait out 'timeoutlen' first.
		--   * `<Leader>d` -- `<C-w>d` is the built-in, and the mapping collided with
		--     the `<leader>d`-prefixed debugger keys.
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		-- Project-specific fix commands; see `:LintFix` below.
		vim.keymap.set("n", "<leader>ef", "<cmd>EslintFixAll<cr>", opts)
		vim.keymap.set("n", "<leader>lf", "<cmd>LintFix<cr>", opts)
	end,
})

-- Setup language servers using the new vim.lsp.config API
-- Python: ruff owns formatting, import ordering and lint; basedpyright owns
-- navigation only. mypy is deliberately not wired in here -- see below.
--
-- Both servers are resolved out of the project's virtualenv (config/venv.lua),
-- so nothing Python-related needs to be installed globally.
local venv = require("config.venv")

-- basedpyright with `typeCheckingMode = "off"`: this is a navigation server
-- (hover, go-to-definition, references, completion), not a type checker.
--
-- ppy's type truth is mypy 2.3.0 plus three custom plugins
-- (sqlalchemy_nullable_plugin, patreon_logger_plugin, pydantic.mypy), forked
-- sqlalchemy2-stubs, and per-module `disallow_untyped_defs`. basedpyright reads
-- none of that, so with checking enabled it disagrees with CI constantly --
-- loudest on SQLAlchemy nullability, which is exactly what that plugin fixes.
-- Run mypy out of band (`dmypy run`) for real type errors.
vim.lsp.config.basedpyright = {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "off",
				-- Whole-project analysis on a repo ppy's size is not worth the RAM
				-- when it is not reporting type errors anyway.
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
	-- Resolve the interpreter from the project rather than hardcoding one venv.
	-- The old pyright block pinned `/home/dev/patreon_py/venv/bin/python`, which
	-- was wrong in every other repo -- and moot, since pyright was never installed
	-- for it to read.
	--
	-- This is `on_init` rather than `before_init` for the same reason as oxlint
	-- below: the client copies `settings` when it is created, so mutating the
	-- config in `before_init` never reaches the server. basedpyright pulls
	-- configuration via `workspace/configuration`, which nvim answers from
	-- `client.settings` -- so update that, then tell it to re-read.
	on_init = function(client)
		local project_venv = venv.find(client.root_dir)
		if not project_venv then
			return
		end

		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			python = { pythonPath = vim.fs.joinpath(project_venv, "bin", "python") },
			basedpyright = {
				analysis = {
					venvPath = vim.fs.dirname(project_venv),
					venv = vim.fs.basename(project_venv),
				},
			},
		})

		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end,
}

-- ruff's built-in language server (`ruff server`, stable since 0.5) -- the
-- separate `ruff-lsp` package is deprecated. It reads the project's
-- pyproject.toml, so ppy's ~200 rule ignores and its isort settings
-- (force-single-line) apply here exactly as they do in pre-commit.
--
-- `cmd` is a function so the binary can be chosen per project: it runs the
-- venv's own ruff, which is the only copy installed anywhere. A function `cmd`
-- is expected to return an RPC client rather than an argv list, so it hands the
-- resolved command to `vim.lsp.rpc.start` itself.
--
-- Note this does *not* cover ppy's flake8 PAT01-PAT32 checks: pyproject sets
-- `lint.external = ["PAT"]`, so ruff knowingly skips them and only the flake8
-- hook runs them. Those stay invisible in the editor for now.
vim.lsp.config.ruff = {
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start({ venv.bin("ruff", config.root_dir), "server" }, dispatchers)
	end,
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
	capabilities = capabilities,
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
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")
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
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

-- `:LintFix` applies every autofix the linters offer, in the same order as prf's
-- pre-commit hook: biome's safe lint fixes plus import sorting, then oxlint's.
-- Pure formatting is conform's job (`<leader>f` / `:Format`), and import sorting
-- also happens there on save -- this command is for the rest.
---Request source actions of the given kinds from one server and apply them.
---
---Servers may return actions unresolved: ruff advertises `resolveProvider` and
---sends back actions with no `edit`, which have to be fetched with
---`codeAction/resolve` before there is anything to apply. Biome resolves up
---front. Handle both, plus actions delivered as a command to execute.
---@param bufnr integer
---@param name string Client name
---@param kinds string[] Code action kinds to request
---@return boolean applied
local function apply_source_actions(bufnr, name, kinds)
	local applied = false

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = name })) do
		local params = {
			textDocument = vim.lsp.util.make_text_document_params(bufnr),
			-- Source actions apply to the whole document; the range is ignored.
			range = {
				start = { line = 0, character = 0 },
				["end"] = { line = 0, character = 0 },
			},
			context = { diagnostics = {}, only = kinds },
		}

		local response = client:request_sync("textDocument/codeAction", params, 5000, bufnr)

		for _, action in ipairs(response and response.result or {}) do
			local edit, command = action.edit, action.command

			if not edit and not command then
				local resolved = client:request_sync("codeAction/resolve", action, 5000, bufnr)
				edit = resolved and resolved.result and resolved.result.edit
				command = resolved and resolved.result and resolved.result.command
			end

			if edit then
				vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
				applied = true
			end

			if command then
				client:exec_cmd(command, { bufnr = bufnr })
				applied = true
			end
		end
	end

	return applied
end

-- oxlint has no source action; its fixes are behind a command instead.
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

	local linters = {
		biome = { "source.fixAll.biome", "source.organizeImports.biome" },
		-- The editor equivalent of ppy's `ruff-check --fix` pre-commit hook.
		ruff = { "source.fixAll.ruff", "source.organizeImports.ruff" },
	}

	local attached, applied = false, false

	for name, kinds in pairs(linters) do
		if #vim.lsp.get_clients({ bufnr = bufnr, name = name }) > 0 then
			attached = true
			applied = apply_source_actions(bufnr, name, kinds) or applied
		end
	end

	if #vim.lsp.get_clients({ bufnr = bufnr, name = "oxlint" }) > 0 then
		attached = true
		applied = apply_oxlint_fixes(bufnr) or applied
	end

	if not attached then
		vim.notify("LintFix: no biome, oxlint or ruff client attached to this buffer", vim.log.levels.WARN)
	elseif not applied then
		vim.notify("LintFix: nothing to fix", vim.log.levels.INFO)
	end
end, {
	desc = "Apply biome + oxlint + ruff autofixes to the current buffer",
})
