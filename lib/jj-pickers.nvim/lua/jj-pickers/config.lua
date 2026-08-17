local M = {}

local defaults = {
  revset = 'trunk()..@',
  limit = 20,
  revision = '@',
  on_revision = 'edit',
  context = 12,
  keys = nil,
}

local config = vim.deepcopy(defaults)

---@param opts? table
function M.setup(opts) config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {}) end

function M.get() return config end

M.defaults = defaults

return M
