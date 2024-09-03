local telescope = require("telescope")
local telescopeConfig = require("telescope.config")
local builtin = require('telescope.builtin')

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

telescope.setup({
	defaults = {
		-- `hidden = true` is not supported in text grep commands.
		vimgrep_arguments = vimgrep_arguments,
		preview = {
			mime_hook = function(filepath, bufnr, opts)
				local is_image = function(filepath)
					local image_extensions = { 'png', 'jpg' } -- Supported image formats
					local split_path = vim.split(filepath:lower(), '.', { plain = true })
					local extension = split_path[#split_path]
					return vim.tbl_contains(image_extensions, extension)
				end
				if is_image(filepath) then
					local term = vim.api.nvim_open_term(bufnr, {})
					local function send_output(_, data, _)
						for _, d in ipairs(data) do
							vim.api.nvim_chan_send(term, d .. '\r\n')
						end
					end


					-- local width = vim.o.columns
					vim.fn.jobstart(
						{
							'viu', '-w', 50, filepath -- Terminal image viewer command
						},
						{ on_stdout = send_output, stdout_buffered = true, pty = true })
				else
					require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
				end
			end
		}
	},
	pickers = {
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
})


vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
-- NOTE: lets see if i use this ever
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
-- projectwide diagnostics
vim.keymap.set('n', '<leader>pd', function() require('telescope.builtin').diagnostics({ severity_bound = 0 }) end, {})
-- vim.keymap.set('n', '<leader>po', builtin.oldfiles, {})
-- NOTE: I dont actually use this so commenting it out for now
-- vim.keymap.set('n', '<C-p>', builtin.git_files, {})
