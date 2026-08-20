-- Single icon provider for the whole config: oil.nvim uses mini.icons directly,
-- while grapple.nvim and fzf-lua ask for nvim-web-devicons.
-- mock_nvim_web_devicons() makes `require("nvim-web-devicons")` resolve to a
-- mini.icons-backed shim, so nvim-web-devicons need not be installed.
require("mini.icons").setup({})
require("mini.icons").mock_nvim_web_devicons()
