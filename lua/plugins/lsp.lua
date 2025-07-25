return {
	{
		"williamboman/mason.nvim", -- Mason for LSP management
		-- event = "VeryLazy", -- Use an appropriate event, like "VeryLazy"
		cond = function()
			local enable_mason = os.getenv("ENABLE_MASON")
			return enable_mason == "true"
		end,
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				-- NOTE: consider vtsls instead of ts_ls
				ensure_installed = { "ts_ls", "eslint", "lua_ls", "biome", "stylelint_lsp" },
				automatic_installation = true,
				automatic_enable = false,
				handlers = {
					function(server_name)
						-- Setup individual LSP server configurations here
						require("lspconfig")[server_name].setup({})
					end,
				},
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		cmd = "LSPInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		init = function()
			-- reserve a space in the gutter
			vim.opt.signcolumn = "yes"
			-- don't show parse errors in a separate window
			vim.g.zig_fmt_parse_errors = 0
			-- disable format-on-save from `ziglang/zig.vim`
			vim.g.zig_fmt_autosave = 0
		end,
		config = function()
			local lsp_defaults = require("lspconfig").util.default_config

			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			lsp_defaults.capabilities =
				vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- LSPAttach is where you enable features that onl workk
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

			-- Setup language servers
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			lspconfig.pyright.setup({
				settings = {
					python = {
						pythonPath = "/home/dev/patreon_py/venv/bin/python",
					},
				},
			})
			lspconfig.pylsp.setup({
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
				root_dir = function(fname)
					local root_files = {
						"requirements.txt",
					}
					return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
				end,
			})
			lspconfig.lua_ls.setup({})
			lspconfig.stylelint_lsp.setup({
				filetypes = { "css", "scss" },
				root_dir = require("lspconfig.util").root_pattern("package.json", ".git"),
				workingDirectory = { mode = "location" }, -- safer than \"auto\" for plugin resolution
				settings = {
					stylelintplus = {
						autoFixOnFormat = true, -- Automatically apply fixes on format requests
						autoFixOnSave = false, -- Automatically apply fixes on save (consider implications with other formatters)
					},
					nodePath = vim.fn.getcwd() .. "/node_modules",
				},
			})
			lspconfig.biome.setup({
				root_dir = require("lspconfig.util").root_pattern("biome.json", ".git"),
				workingDirectory = { mode = "location" }, -- safer than \"auto\" for plugin resolution
				settings = {
					nodePath = vim.fn.getcwd() .. "/node_modules",
				},
			})
			lspconfig.eslint.setup({
				root_dir = require("lspconfig.util").root_pattern(".eslintrc.js", "package.json"),
				workingDirectory = { mode = "location" }, -- safer than \"auto\" for plugin resolution
				settings = {
					autoFixOnSave = true,
					nodePath = vim.fn.getcwd() .. "/node_modules",
				},
			})
			lspconfig.ts_ls.setup({})
			lspconfig.ccls.setup({})
			lspconfig.zls.setup({
				settings = {
					zls = {
						enable_build_on_save = true,
						build_on_save_step = "check",
					},
				},
			})

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "",
						[vim.diagnostic.severity.HINT] = "",
						[vim.diagnostic.severity.INFO] = "",
					},
				},
				virtual_text = {
					prefix = "●",
				},
				update_in_insert = false,
				underline = true,
				severity_sort = true,
			})
		end,
	},
}
