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

vim.lsp.config.stylelint_lsp = {
	cmd = { "stylelint-lsp", "--stdio" },
	filetypes = { "css", "scss" },
	root_markers = { "package.json", ".git" },
	capabilities = capabilities,
	settings = {
		stylelintplus = {
			autoFixOnFormat = true,
			autoFixOnSave = false,
		},
		nodePath = vim.fn.getcwd() .. "/node_modules",
	},
}

vim.lsp.config.biome = {
	cmd = { "biome", "lsp-proxy" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"typescript",
		"typescript.tsx",
		"typescriptreact",
	},
	root_markers = { "biome.json", ".git" },
	capabilities = capabilities,
	settings = {
		nodePath = vim.fn.getcwd() .. "/node_modules",
	},
}

vim.lsp.config.eslint = {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro" },
	root_markers = { ".eslintrc.js", "package.json", ".git" },
	capabilities = capabilities,
	settings = {
		autoFixOnSave = true,
		nodePath = vim.fn.getcwd() .. "/node_modules",
	},
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
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})
