vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- No `smartindent`: it fights the treesitter `indentexpr` set in
-- config/treesitter.lua, and the bundled indent scripts handle the rest.

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
-- Preview `:s` in a split, so replacements outside the viewport are visible
-- before committing. Pairs with the `<leader>s` maps in config/remap.lua.
vim.opt.inccommand = "split"

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Rounded borders for every float (hover, signature help, diagnostics). The
-- per-plugin `border = "rounded"` settings in plugins/oil.lua, which-key and the
-- diagnostic config now just restate this.
vim.opt.winborder = "rounded"

-- Open splits down and to the right rather than up and to the left.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Prompt on `:q` with unsaved changes instead of failing with E37.
vim.opt.confirm = true

-- Show tabs and trailing whitespace (`listchars` defaults to
-- "tab:> ,trail:-,nbsp:+").
vim.opt.list = true

-- vim.opt.colorcolumn = "80"
