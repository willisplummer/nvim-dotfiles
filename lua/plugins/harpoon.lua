require("grapple").setup({
	scope = "git", -- also try out "git_branch"
	icons = true, -- served by mini.icons via mock_nvim_web_devicons() (plugins/icons.lua)
	status = false,
})

vim.keymap.set("n", "<leader>a", "<cmd>Grapple toggle<cr>", { desc = "Tag a file" })
vim.keymap.set("n", "<leader>e", "<cmd>Grapple toggle_tags<cr>", { desc = "Toggle tags menu" })

vim.keymap.set("n", "<leader>1", "<cmd>Grapple select index=1<cr>", { desc = "Select first tag" })
vim.keymap.set("n", "<leader>2", "<cmd>Grapple select index=2<cr>", { desc = "Select second tag" })
vim.keymap.set("n", "<leader>3", "<cmd>Grapple select index=3<cr>", { desc = "Select third tag" })
vim.keymap.set("n", "<leader>4", "<cmd>Grapple select index=4<cr>", { desc = "Select fourth tag" })
