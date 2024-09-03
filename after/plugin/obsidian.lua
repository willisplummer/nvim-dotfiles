require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/obsidian-vault",
    },
  },

  disable_frontmatter = true,
  ---@param spec { id: string, dir: obsidian.Path, title: string|? }
  ---@return string|obsidian.Path The full path to the new note.
  note_path_func = function(spec)
    -- This is equivalent to the default behavior.
    local path = spec.dir / tostring(spec.title or spec.id)
    return path:with_suffix(".md")
  end,


  mappings = {
    ["<leader>zt"] = {
      action = function()
        return require('obsidian').util.toggle_checkbox()
      end,
      opts = { buffer = true },
    },
  },
  ui = {
    checkboxes = {
      [" "] = { char = "☐", hl_group = "ObsidianTodo" },
      ["x"] = { char = "✔", hl_group = "ObsidianDone" },
    }
  },

  notes_subdir = "00 Inbox",
  new_notes_location = "notes_subdir",

  templates = {
    folder = "03 Templates"
  },

  daily_notes = {
    folder = "01 Journal",
    template = "Default.md"
  }
})

vim.keymap.set("n", "<leader>oo", ":ObsidianOpen<cr>")
vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>")
vim.keymap.set("n", "<leader>ont", ":ObsidianNewFromTemplate<cr>")
vim.keymap.set("n", "<leader>ot", ":ObsidianToday<cr>")
