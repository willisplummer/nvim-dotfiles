-- Diagnostics that no language server provides.
--
-- Python has two of these in ppy:
--   * flake8 runs the repo's custom PAT01-PAT32 plugins (banned imports, missing
--     request timeouts, ...). `pyproject.toml` sets `lint.external = ["PAT"]`, so
--     ruff knowingly skips them -- without this they are invisible until
--     pre-commit rejects the commit.
--   * mypy is the type authority (custom plugins, forked sqlalchemy stubs), and
--     basedpyright deliberately reports no types. See plugins/lsp.lua.
--
-- Everything is resolved out of the project's virtualenv (config/venv.lua).
local lint = require("lint")
local venv = require("config.venv")

local flake8 = lint.linters.flake8
flake8.cmd = function()
	return venv.bin("flake8")
end

-- The PAT plugins match on repo-relative paths (`patreon/*`), so an absolute
-- `--stdin-display-name` -- which is what nvim-lint passes by default -- makes
-- flake8 report nothing at all rather than erroring. Send a relative path.
flake8.args = {
	"--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s",
	"--no-show-source",
	"--stdin-display-name",
	function()
		local name = vim.api.nvim_buf_get_name(0)
		local root = vim.fs.root(0, { "setup.cfg", "pyproject.toml", ".git" })
		return root and vim.fs.relpath(root, name) or name
	end,
	"-",
}

-- ppy's PAT messages embed their own code ("PAT14: Do not check in print
-- statements."), so flake8 splits off `PAT14` and leaves the message starting
-- with a stray colon. Same pattern as nvim-lint's builtin, minus that.
flake8.parser = require("lint.parser").from_pattern(
	"[^:]+:(%d+):(%d+):(%w+):%s*:?%s*(.+)",
	{ "lnum", "col", "code", "message" },
	nil,
	{ source = "flake8", severity = vim.diagnostic.severity.WARN }
)

-- `dmypy` rather than `mypy`: a cold run on ppy takes minutes, while the daemon
-- reuses .mypy_cache and answers in seconds. Flags mirror scripts/typecheck.sh.
-- Output covers the whole project; nvim-lint filters it to the current buffer by
-- matching the `file` capture against the buffer path.
local dmypy = lint.linters.dmypy
dmypy.cmd = function()
	return venv.bin("dmypy")
end
dmypy.args = {
	"run",
	"--timeout",
	-- Daemon idle shutdown, not a per-run limit -- keep it alive for a workday.
	"28800",
	"--",
	"--show-column-numbers",
	"--show-error-end",
	"--hide-error-context",
	"--no-color-output",
	"--no-error-summary",
	"--no-pretty",
	-- Allows loading from a cache written by a `--cache-fine-grained` run, which
	-- is what `[tool.mypy] cache_fine_grained` in ppy produces.
	"--use-fine-grained-cache",
	"--python-executable",
	function()
		local project_venv = venv.find_from(0)
		return project_venv and vim.fs.joinpath(project_venv, "bin", "python") or vim.fn.exepath("python3")
	end,
}

-- Linters that are cheap enough to run on every write. dmypy is deliberately
-- absent: it re-checks the entire project, and ppy's own pre-commit hook budgets
-- it 5 seconds and gives up. It runs on demand instead (`:Typecheck` below).
lint.linters_by_ft = {
	python = { "flake8" },
}

---Run linters from the project's venv, skipping any whose binary is missing so
---repos without the tool installed do not produce an error on every save.
---@param names string[]|nil Defaults to the filetype's configured linters
local function run(names)
	names = names or lint.linters_by_ft[vim.bo.filetype] or {}

	local runnable = vim.iter(names)
		:filter(function(name)
			local linter = lint.linters[name]
			local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
			return vim.fn.executable(cmd) == 1
		end)
		:totable()

	if #runnable == 0 then
		return false
	end

	-- dmypy must run from the project root: it reads pyproject.toml from there,
	-- and nvim-lint resolves the relative paths in its output against this cwd.
	lint.try_lint(runnable, { cwd = vim.fs.root(0, { "pyproject.toml", "setup.cfg", ".git" }) })
	return true
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	desc = "Run fast linters",
	callback = function()
		run()
	end,
})

vim.api.nvim_create_user_command("Typecheck", function()
	if not run({ "dmypy" }) then
		vim.notify("Typecheck: no dmypy in this project's venv", vim.log.levels.WARN)
		return
	end

	-- The first run after a cold start blocks for minutes while the daemon builds
	-- its cache, and nvim-lint gives no feedback until results land.
	vim.notify("Typecheck: running dmypy...", vim.log.levels.INFO)
end, {
	desc = "Type check the current buffer with dmypy (whole-project run)",
})

vim.keymap.set("n", "<leader>lt", "<cmd>Typecheck<cr>", { desc = "Type check with dmypy" })
