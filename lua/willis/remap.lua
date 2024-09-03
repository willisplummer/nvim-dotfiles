vim.g.mapleader = " "

-- easier exit to file tree -- 'project view'
vim.keymap.set("n", "<leader>pv", '<Cmd>Oil<CR>')

-- copy and paste
vim.keymap.set('', '<leader>y', '"*y', { desc = 'yank to clipboard' })
vim.keymap.set('', '<leader>Y', '"*Y', { desc = 'yank until EOL to clipboard' })

vim.keymap.set('n', '<leader>p', '"*p', { desc = 'paste after cursor from clipboard' })
vim.keymap.set('n', '<leader>P', '"*P', { desc = 'paste before cursor from clipboard' })

-- jump highighted text (visual mode) up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- joins the line with the one below it
-- TBD if i'll keep these - so far it's been
-- mostly unintentional and stressful
vim.keymap.set("n", "J", "mzJ`z")

--centered jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- just centers you after jumping between
-- search results - p good
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- while highlighting text, replace with yanked
-- but keep yanked text in the register
--"greatest remap ever" ... idk
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- reload vimrc file
-- vim.keymap.set("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end)
