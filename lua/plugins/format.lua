return {
	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<leader>tf",
				function()
					-- If autoformat is currently disabled for this buffer,
					-- then enable it, otherwise disable it
					if vim.b.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("Enabled autoformat for current buffer")
					else
						vim.cmd("FormatDisable!")
						vim.notify("Disabled autoformat for current buffer")
					end
				end,
				desc = "Toggle autoformat for current buffer",
			},
			{
				"<leader>tF",
				function()
					-- If autoformat is currently disabled globally,
					-- then enable it globally, otherwise disable it globally
					if vim.g.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("Enabled autoformat globally")
					else
						vim.cmd("FormatDisable")
						vim.notify("Disabled autoformat globally")
					end
				end,
				desc = "Toggle autoformat globally",
			},
		},
		opts = {
			-- Map of filetype to formatters
			formatters_by_ft = {
				lua = { "stylua" },
				-- Conform will run multiple formatters sequentially
				-- python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				nix = { "nixfmt", stop_after_first = true },
				zig = { "zigfmt", stop_after_first = true },
				-- Use the "*" filetype to run formatters on all filetypes.
				-- ["*"] = { "codespell" },
				-- Use the "_" filetype to run formatters on filetypes that don't
				-- have other formatters configured.
				["_"] = { "trim_whitespace" },
			},
			-- If this is set, Conform will run the formatter on save.
			-- It will pass the table to conform.format().
			-- This can also be a function that returns the table.
			format_on_save = {
				-- I recommend these options. See :help conform.format for details.
				lsp_fallback = true,
				timeout_ms = 500,
			},
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- :FormatDisable! disables autoformat for this buffer only
					vim.b.disable_autoformat = true
				else
					-- :FormatDisable disables autoformat globally
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true, -- allows the ! variant
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})

			vim.keymap.set("n", "<leader>f", function()
				conform.format({ async = true })
			end)
		end,
	},
	{
		"nmac427/guess-indent.nvim",
		opts = {},
	},
}
