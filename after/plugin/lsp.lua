local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({ buffer = bufnr })
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.skip_server_setup({ 'rust_analyzer' })

lsp.setup()

-- referencing nvim-web-devicons
lsp.set_sign_icons({
  error = "",
  warn = "",
  hint = "",
  info = "",
  other = "",
})


local cmp = require('cmp')
local rust_tools = require('rust-tools')

rust_tools.setup({
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, { buffer = bufnr })
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy"
        }
      }
    }
  }
})

-- lsp.format_on_save({
--   format_opts = {
--     async = false,
--     timeout_ms = 10000,
--   },
--   servers = {
--     ['tsserver'] = {'javascript', 'typescript'},
--     ['rust_analyzer'] = {'rust'},
--   }
-- })
--

cmp.setup({
  mapping = {
    ['<TAB>'] = cmp.mapping.confirm({ select = true }),
  }
})

vim.api.nvim_set_keymap(
  'n', '<Leader>d', ':lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true }
)
