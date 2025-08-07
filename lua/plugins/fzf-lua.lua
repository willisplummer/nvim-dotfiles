return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		
		fzf.setup({
			winopts = {
				preview = {
					default = "builtin",
					builtin = {
						extensions = {
							["png"] = { "viu", "-w", "50" },
							["jpg"] = { "viu", "-w", "50" },
						},
					},
				},
			},
			files = {
				fd_opts = "--color=never --type f --hidden --follow --exclude .git",
				rg_opts = "--color=never --files --hidden --follow -g '!.git'",
			},
			grep = {
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' --max-columns=512",
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>pf", fzf.files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>ps", fzf.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>pb", fzf.buffers, { desc = "Buffers" })
		vim.keymap.set("n", "<leader>pd", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })
	end,
}