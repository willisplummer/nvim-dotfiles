vim.opt.timeout = true 
vim.opt.timeoutlen = 300

local function load_env_file(path)
	local file = io.open(path, "r")
	if not file then
		return
	end

	for line in file:lines() do
		local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
		if key and value then
			vim.fn.setenv(key, value)
		end
	end

	file:close()
end

load_env_file(vim.fn.stdpath("config") .. "/.env")

require("config.lazy")
