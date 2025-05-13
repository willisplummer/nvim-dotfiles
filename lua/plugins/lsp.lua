return {
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
				end,
			})

			-- Setup language servers
			local lspconfig = require("lspconfig")
			lspconfig.tsserver.setup({})
			lspconfig.lua_ls.setup({})
			lspconfig.ccls.setup({})
			lspconfig.zls.setup({
				settings = {
					zls = {
						enable_build_on_save = true,
						build_on_save_step = "check",
					},
				},
			})

			-- Set custom icons for LSP diagnostics
			vim.fn.sign_define(
				"DiagnosticSignError",
				{ text = "", texthl = "DiagnosticSignError", numhl = "DiagnosticSignError" }
			)
			vim.fn.sign_define(
				"DiagnosticSignWarn",
				{ text = "", texthl = "DiagnosticSignWarn", numhl = "DiagnosticSignWarn" }
			)
			vim.fn.sign_define(
				"DiagnosticSignHint",
				{ text = "", texthl = "DiagnosticSignHint", numhl = "DiagnosticSignHint" }
			)
			vim.fn.sign_define(
				"DiagnosticSignInfo",
				{ text = "", texthl = "DiagnosticSignInfo", numhl = "DiagnosticSignInfo" }
			)

			-- Set custom LSP diagnostic icons
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●", -- You can change this to something else like '▶', '✪', etc.
				},
				signs = true,
				update_in_insert = false,
				underline = true,
				severity_sort = true,
			})
		end,
	},
}
