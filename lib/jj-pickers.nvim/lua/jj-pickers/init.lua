local M = {}

local SOURCES = { jj_changes = 'changes', jj_revisions = 'revisions' }

local registered

local function register()
  if registered ~= nil then return registered end
  registered = pcall(function()
    for name, mod in pairs(SOURCES) do
      Snacks.picker.sources[name] = require('jj-pickers.sources.' .. mod).source
    end
  end)
  return registered
end

local function pick(name, opts)
  if not (rawget(_G, 'Snacks') and Snacks.picker) then
    vim.notify('jj-pickers needs folke/snacks.nvim with `picker` enabled', vim.log.levels.ERROR, { title = 'jj-pickers' })
    return nil
  end
  require('jj-pickers.highlights').setup()
  local source = require('jj-pickers.sources.' .. SOURCES[name])
  local cfg = vim.tbl_deep_extend('force', vim.deepcopy(require('jj-pickers.config').get()), opts or {})
  local resolved = source.opts(cfg)
  if not resolved then return nil end
  if register() then return Snacks.picker.pick(name, resolved) end
  return Snacks.picker.pick(vim.tbl_deep_extend('force', { source = name }, source.source, resolved))
end

--- Files changed in a revision (default `@`).
---@param opts? table
function M.changes(opts) return pick('jj_changes', opts) end

--- Revisions matching a revset (default `trunk()..@`).
---@param opts? table
function M.revisions(opts) return pick('jj_revisions', opts) end

---@param opts? table
function M.setup(opts)
  require('jj-pickers.config').setup(opts)
  if rawget(_G, 'Snacks') and Snacks.picker then register() end
  for name, lhs in pairs(require('jj-pickers.config').get().keys or {}) do
    if type(M[name]) == 'function' then vim.keymap.set('n', lhs, function() M[name]() end, { desc = 'jj-pickers: ' .. name }) end
  end
end

return M
