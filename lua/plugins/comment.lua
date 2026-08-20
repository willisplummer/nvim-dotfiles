-- Commenting is Neovim's built-in `gc`/`gcc` (see `:h commenting`); this module
-- only teaches it about context.
--
-- Neovim resolves 'commentstring' from treesitter on its own, in two ways:
-- `bo.commentstring` metadata on a highlight capture (nvim-treesitter ships this
-- for jsx and vue), then a walk down the LanguageTree for injected languages
-- (markdown code fences, html-in-js). That covers most cases without help.
--
-- ts-context-commentstring is kept for the rest: languages where the comment
-- syntax changes *within a single grammar* and no capture metadata exists
-- (svelte, astro, handlebars, twig, ...). It hooks in below.
vim.g.skip_ts_context_commentstring_module = true

-- `enable_autocmd = false`: the default recalculates on CursorHold, which is
-- pointless when the hook below computes on demand.
require("ts_context_commentstring").setup({ enable_autocmd = false })

-- Neovim's commenting calls `vim.filetype.get_option(ft, "commentstring")` to
-- resolve the string at the cursor, so wrapping that is the whole integration.
-- Note capture metadata takes precedence over this, so in tsx the query wins and
-- this is never consulted -- both produce `{/* %s */}` anyway.
local get_option = vim.filetype.get_option

vim.filetype.get_option = function(filetype, option)
	if option ~= "commentstring" then
		return get_option(filetype, option)
	end

	-- Returns nil when treesitter is not active or the cursor is not in a known
	-- context; fall back to the normal lookup then.
	return require("ts_context_commentstring.internal").calculate_commentstring()
		or get_option(filetype, option)
end
