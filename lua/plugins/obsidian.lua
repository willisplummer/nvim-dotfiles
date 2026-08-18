-- Gated on ENABLE_OBSIDIAN; the spec and this module are wired up in config.pack.
require("obsidian").setup({
	workspaces = {
		{
			name = "personal",
			path = "~/obsidian-vault",
		},
	},
	disable_frontmatter = true,

	note_path_func = function(spec)
		-- This is equivalent to the default behavior.
		local path = spec.dir / tostring(spec.title or spec.id)
		return path:with_suffix(".md")
	end,
	mappings = {
		["<cr>"] = {
			action = function()
				if require("obsidian").util.cursor_on_markdown_link(nil, nil, true) then
					return "<cmd>ObsidianFollowLink<CR>"
				end
			end,
			opts = { expr = true, buffer = true },
		},
	},

	ui = {
		enable = false,
	},

	notes_subdir = "00 Inbox",
	new_notes_location = "notes_subdir",

	templates = {
		folder = "03 Templates",
	},

	daily_notes = {
		folder = "01 Journal",
		template = "Default.md",
	},

	--
	-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
	-- URL it will be ignored but you can customize this behavior here.
	---@param url string
	follow_url_func = function(url)
		vim.ui.open(url) -- need Neovim 0.10.0+
	end,
})

vim.keymap.set("n", "<leader>oo", ":ObsidianOpen<cr>")
vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>")
vim.keymap.set("n", "<leader>ont", ":ObsidianNewFromTemplate<cr>")
vim.keymap.set("n", "<leader>ot", ":ObsidianToday<cr>")
