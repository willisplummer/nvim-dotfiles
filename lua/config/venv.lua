-- Locating a project's Python virtualenv and the tools inside it.
--
-- Python tooling is installed per-repo rather than globally: ppy pins
-- ruff 0.16.0 in dev-requirements.in, and `ruff format` output is not stable
-- across versions, so formatting with a different binary means saving a file
-- produces a diff CI disagrees with. This is the same reasoning that makes
-- nvim-lspconfig prefer `node_modules/.bin/biome` over a global install.
local M = {}

local markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", ".git" }

---@param root string|nil
---@return string|nil venv Absolute path to the virtualenv directory
function M.find(root)
	if not root then
		return nil
	end

	for _, dir in ipairs({ "venv", ".venv" }) do
		local venv = vim.fs.joinpath(root, dir)
		if vim.uv.fs_stat(vim.fs.joinpath(venv, "bin", "python")) then
			return venv
		end
	end
end

---@param source integer|string|nil Buffer number, or a directory to search from
---@return string|nil venv
function M.find_from(source)
	local root = type(source) == "string" and source or vim.fs.root(source or 0, markers)
	return M.find(root)
end

---Path to a tool in the project's virtualenv, or the bare name as a fallback so
---anything on $PATH still works outside a Python project.
---@param name string
---@param source integer|string|nil Buffer number, or a directory to search from
---@return string
function M.bin(name, source)
	local venv = M.find_from(source)
	local path = venv and vim.fs.joinpath(venv, "bin", name)

	if path and vim.uv.fs_stat(path) then
		return path
	end

	return name
end

return M
