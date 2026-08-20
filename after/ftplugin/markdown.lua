-- Checkbox toggling for markdown lists. Cycles a line through
-- `text` -> `- [ ] text` -> `- [x] text` -> `- text`, and `- text` -> `- [ ] text`.
--
-- This lived in `after/plugin/` as a global `ToggleTodo()` with a global keymap,
-- so it was defined in every buffer of every filetype. Nothing here needs to be
-- reachable from outside markdown.
local function toggle(opts)
	opts = opts or {}

	local first, last = opts.line1, opts.line2
	if not first or not last then
		first = vim.api.nvim_win_get_cursor(0)[1]
		last = first
	end

	if first > last then
		first, last = last, first
	end

	for lnum = first, last do
		local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
		local stripped = vim.trim(line)
		local toggled

		if vim.startswith(stripped, "- [ ]") then
			toggled = line:gsub("%- %[ %]", "- [x]", 1)
		elseif vim.startswith(stripped, "- [x]") then
			-- `onlyTodo` resets to unchecked instead of dropping the checkbox.
			toggled = opts.onlyTodo and line:gsub("%- %[x%]", "- [ ]", 1) or line:gsub("%- %[x%]", "-", 1)
		elseif vim.startswith(stripped, "- ") then
			toggled = line:gsub("%- ", "- [ ] ", 1)
		else
			toggled = line:gsub("(%S)", "- [ ] %1", 1)
		end

		vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { toggled })
	end
end

vim.keymap.set("n", "<leader>zt", toggle, { buffer = true, desc = "Toggle todo checkbox" })

-- `line("v")` is the other end of the selection while still in visual mode, so
-- there is no need to leave it first and read the `'<`/`'>` marks.
vim.keymap.set("x", "<leader>zt", function()
	toggle({ line1 = vim.fn.line("v"), line2 = vim.fn.line(".") })
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end, { buffer = true, desc = "Toggle todo checkboxes in selection" })
