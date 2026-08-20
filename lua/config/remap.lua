vim.g.mapleader = " "

-- copy and paste --
vim.keymap.set("", "<leader>y", '"*y', { desc = "yank to clipboard" })
vim.keymap.set("", "<leader>Y", '"*Y', { desc = "yank until EOL to clipboard" })

vim.keymap.set("n", "<leader>pp", '"*p', { desc = "paste after cursor from clipboard" })
vim.keymap.set("n", "<leader>PP", '"*P', { desc = "paste before cursor from clipboard" })

-- while highlighting text, replace with yanked
-- and keep yanked text in the register
vim.keymap.set("x", "<leader>p", [["_dP]])

----

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

-- disable default Q mode
vim.keymap.set("n", "Q", "<nop>")
-- open tmux sessionizer from inside nvim
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- find and replace the word under the cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Same, but for the visual selection. `getregion` reads the selected text
-- without going through a register, so it does not clobber the unnamed one.
-- `\V` makes the pattern literal (very nomagic), since a selection is arbitrary
-- text rather than a word -- no `\<`/`\>` boundaries for the same reason.
vim.keymap.set("x", "<leader>s", function()
	local mode = vim.fn.mode()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
	local selection = table.concat(lines, "\n")

	local pattern = vim.fn.escape(selection, [[\/]]):gsub("\n", [[\n]])
	local replacement = vim.fn.escape(selection, [[\/&~]]):gsub("\n", [[\r]])

	local keys = ("<Esc>:%%s/\\V%s/%s/gI<Left><Left><Left>"):format(pattern, replacement)
	vim.api.nvim_feedkeys(vim.keycode(keys), "n", false)
end, { desc = "find and replace the visual selection" })
