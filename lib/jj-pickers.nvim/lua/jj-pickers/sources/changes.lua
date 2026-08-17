local jj = require 'jj-pickers.jj'

local M = {}

local STATUS = {
  A = { icon = 'added', hl = 'SnacksPickerGitStatusAdded' },
  M = { icon = 'modified', hl = 'SnacksPickerGitStatusModified' },
  D = { icon = 'deleted', hl = 'SnacksPickerGitStatusDeleted' },
  R = { icon = 'renamed', hl = 'SnacksPickerGitStatusRenamed' },
  C = { hl = 'SnacksPickerGitStatusCopied' },
}

---@type snacks.picker.finder
function M.finder(opts, ctx)
  if not opts.jj_root then return {} end
  return require('snacks.picker.source.proc').proc(
    ctx:opts {
      cmd = 'jj',
      args = jj.diff_args({ root = opts.jj_root }, opts.jj_revision),
      cwd = opts.jj_root,
      transform = function(item)
        local status, path, abs = item.text:match '^(.-)\t(.-)\t(.*)$'
        if not status then return false end
        item.status = status
        item.cwd = opts.jj_root
        item.file = path
        item.jj_abs = abs
        item.jj_root = opts.jj_root
        item.jj_revision = opts.jj_revision
        item.text = path
      end,
    },
    ctx
  )
end

---@param item snacks.picker.Item
---@param picker snacks.Picker
function M.format(item, picker)
  local spec = STATUS[item.status] or { hl = 'SnacksPickerGitStatus' }
  local icons = picker.opts.icons.git
  local glyph = (icons.enabled and spec.icon) and icons[spec.icon] or item.status
  local ret = {}
  ret[#ret + 1] = { Snacks.picker.util.align(glyph, 2), spec.hl, virtual = true }
  item.filename_hl = spec.hl
  vim.list_extend(ret, Snacks.picker.format.filename(item, picker))
  return ret
end

---@param ctx snacks.picker.preview.ctx
function M.preview(ctx)
  local item = ctx.item
  local o = { root = item.jj_root, stale = true }
  local cmd = jj.cmd(jj.file_diff_args(o, item.jj_revision, item.file, ctx.picker.opts.jj_context))
  return require('jj-pickers.preview').diff(ctx, cmd, { ft = 'diff', cwd = item.jj_root, title = item.file, center = true })
end

-- Resolved here rather than on the item, because a `jj diff` per row costs ~30ms and snacks
-- resolves every row it renders; this way it runs once, on the file actually being opened.
function M.confirm(picker, item, action)
  if item and item.status == 'D' then
    picker:norm(function() picker:close() end)
    vim.notify(('%s was deleted in %s — nothing to open'):format(item.file, item.jj_revision), vim.log.levels.WARN, { title = 'jj-pickers' })
    return
  end
  if item and not item.pos then
    local line = jj.first_hunk_line({ root = item.jj_root, stale = true }, item.jj_revision, item.file)
    if line then item.pos = { line, 0 } end
  end
  return Snacks.picker.actions.jump(picker, item, action)
end

function M.opts(cfg)
  local root = jj.guard(cfg.path)
  if not root then return nil end
  return {
    cwd = root,
    title = ('jj changes %s'):format(cfg.revision),
    jj_root = root,
    jj_revision = cfg.revision,
    jj_context = cfg.context,
  }
end

M.source = {
  finder = M.finder,
  format = M.format,
  preview = M.preview,
  confirm = M.confirm,
  sort = { fields = { 'score:desc', 'idx' } },
  config = function(opts)
    require('jj-pickers.highlights').setup()
    if opts.jj_root then return opts end
    local resolved = M.opts(require('jj-pickers.config').get())
    return resolved and vim.tbl_deep_extend('keep', opts, resolved) or opts
  end,
  actions = {
    jj_yank_path = { action = 'yank', field = 'jj_abs', reg = '+' },
    jj_revisions = function(picker, item)
      picker:close()
      require('jj-pickers').revisions { path = item and item.jj_root or nil }
    end,
  },
  win = {
    input = {
      keys = {
        ['<c-o>'] = { 'jj_revisions', mode = { 'n', 'i' } },
        ['<c-y>'] = { 'jj_yank_path', mode = { 'n', 'i' } },
      },
    },
    list = {
      keys = {
        ['<c-o>'] = 'jj_revisions',
        ['<c-y>'] = 'jj_yank_path',
      },
    },
  },
}

return M
