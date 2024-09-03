local dap = require "dap"
local ui = require "dapui"

require "dapui".setup()
require "nvim-dap-virtual-text".setup()
require "mason".setup()
require "mason-nvim-dap".setup({
  ensure_installed = { 'codelldb', 'stylua', 'jq' },
  handlers = {}, -- sets up dap in the predefined manner
})



vim.keymap.set("n", "<leader>?", function()
  ui.eval(nil, { enter = true })
end)

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dr", dap.continue)

dap.listeners.before.attach.dapui_config = function()
  ui.open()
end
dap.listeners.before.launch.dapui_config = function()
  ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  ui.close()
end
