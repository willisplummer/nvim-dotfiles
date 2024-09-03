require("tokyonight").setup({
  -- use the night style
  style = "storm",

  transparent = true,

  -- disable italic for functions
  styles = {
    functions = {},
    -- sidebars = "transparent",
    -- floats = "dark"
  },
})

-- options are tokyonight-storm, tokyonight-moon, tokyonight-night, tokyonight-day
vim.cmd [[colorscheme tokyonight]]
