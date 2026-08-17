local jj = require 'jj-pickers.jj'

local M = {}

-- Column contract for jj.templates.revision. Keep the two adjacent.
local PATTERN = '^' .. ('(.-)\t'):rep(9) .. '(.*)$'

local BOOKMARK = '\xEE\x82\xA0 '

---@type snacks.picker.finder
function M.finder(opts, ctx)
  if not opts.jj_root then return {} end
  local o = { root = opts.jj_root, stale = true }
  local limit = not opts.all and opts.jj_limit or nil
  return require('snacks.picker.source.proc').proc(
    ctx:opts {
      cmd = 'jj',
      args = jj.log_args(o, opts.jj_revset, limit),
      cwd = opts.jj_root,
      transform = function(item)
        local prefix, change, commit, wc, imm, conflict, empty, marks, ago, msg = item.text:match(PATTERN)
        if not change then return false end
        item.change_prefix, item.change_id, item.commit_id = prefix, change, commit
        item.current = wc == '1'
        item.immutable = imm == '1'
        item.conflict = conflict == '1'
        item.jj_empty = empty == '1'
        item.bookmarks, item.ago = marks, ago
        item.desc = msg
        item.msg = msg ~= '' and msg or '(no description set)'
        item.jj_root = opts.jj_root
        item.cwd = opts.jj_root
        item.text = table.concat({ change, commit, item.msg, marks }, ' ')
      end,
    },
    ctx
  )
end

---@param item snacks.picker.Item
---@param picker snacks.Picker
function M.format(item, picker)
  local a = Snacks.picker.util.align
  local ret = {}

  local node, node_hl = '○', 'SnacksPickerTree'
  if item.current then
    node, node_hl = '@', 'SnacksPickerJJCurrent'
  elseif item.immutable then
    node, node_hl = '◆', 'SnacksPickerJJImmutable'
  end
  ret[#ret + 1] = { a(node, 2), node_hl, virtual = true }

  local prefix = (item.change_prefix or ''):sub(1, 8)
  if prefix == '' then prefix = item.change_id:sub(1, 4) end
  ret[#ret + 1] = { prefix, 'SnacksPickerJJChangeId' }
  ret[#ret + 1] = { a(item.change_id:sub(#prefix + 1), 8 - #prefix), 'SnacksPickerDimmed' }
  ret[#ret + 1] = { ' ' }

  if item.conflict then
    ret[#ret + 1] = { a(picker.opts.icons.git.unmerged, 2), 'SnacksPickerGitStatusUnmerged', virtual = true }
  elseif item.bookmarks ~= '' then
    ret[#ret + 1] = { a(BOOKMARK, 2), 'SnacksPickerGitBranch', virtual = true }
  else
    ret[#ret + 1] = { a('', 2) }
  end

  ret[#ret + 1] = { a(item.ago, 13, { truncate = true }), 'SnacksPickerGitDate' }
  ret[#ret + 1] = { ' ' }

  local msg_hl = item.desc ~= '' and 'SnacksPickerGitMsg' or 'SnacksPickerDimmed'
  ret[#ret + 1] = {
    '',
    resolve = function(max_width)
      local out = {}
      if item.jj_empty then
        out[#out + 1] = { '(empty) ', 'SnacksPickerJJEmpty' }
        max_width = max_width - 8
      end
      out[#out + 1] = { Snacks.picker.util.truncate(item.msg, math.max(max_width, 1)), msg_hl }
      return out
    end,
  }

  return ret
end

---@param ctx snacks.picker.preview.ctx
function M.preview(ctx)
  local item = ctx.item
  local cmd = jj.cmd(jj.show_args({ root = item.jj_root, stale = true }, item.change_id))
  local title = ('%s  %s'):format(item.change_id, item.msg)
  return require('jj-pickers.preview').diff(ctx, cmd, { ft = 'git', cwd = item.jj_root, title = title })
end

local function run(picker, item, verb)
  picker:norm(function() picker:close() end)
  local cmd = jj.cmd(jj.switch_args({ root = item.jj_root }, verb, item.change_id))
  vim.system(
    cmd,
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        local err = vim.trim(vim.split(res.stderr or '', '\n', { plain = true })[1] or '')
        local hint = err:find 'immutable' and '  (press <a-n> for `jj new` instead)' or ''
        vim.notify(('jj %s failed: %s%s'):format(verb, err ~= '' and err or ('exit ' .. res.code), hint), vim.log.levels.ERROR, { title = 'jj-pickers' })
        return
      end
      vim.cmd.checktime()
      vim.api.nvim_exec_autocmds('User', { pattern = 'JjPickersWorkingCopy', data = { root = item.jj_root, change_id = item.change_id, verb = verb } })
      vim.notify(('jj %s %s — %s'):format(verb, item.change_id, item.msg), vim.log.levels.INFO, { title = 'jj-pickers' })
    end)
  )
end

local function switch(picker, item, verb)
  if not item then return end
  if verb == 'edit' and item.current then
    vim.notify('already editing this revision', vim.log.levels.INFO, { title = 'jj-pickers' })
    picker:norm(function() picker:close() end)
    return
  end
  if verb == 'edit' and item.immutable then
    vim.notify(('%s is immutable — press <a-n> to start a new change on top of it'):format(item.change_id), vim.log.levels.WARN, { title = 'jj-pickers' })
    return
  end
  -- jj snapshots the working copy from disk, so an unwritten buffer still belongs to the
  -- revision being left; saving it afterwards would land the work in a different change.
  local dirty = vim.tbl_filter(function(b) return b.name ~= '' end, vim.fn.getbufinfo { bufmodified = 1, buflisted = 1 })
  if #dirty > 0 then
    Snacks.picker.util.confirm(
      ('%d unsaved buffer(s) belong to the current revision. jj %s anyway?'):format(#dirty, verb),
      function() run(picker, item, verb) end
    )
    return
  end
  run(picker, item, verb)
end

function M.confirm(picker, item) switch(picker, item, picker.opts.jj_on_revision == 'new' and 'new' or 'edit') end

function M.opts(cfg)
  local root = jj.guard(cfg.path)
  if not root then return nil end
  local o = { root = root, stale = true }
  local revset = cfg.revset
  if revset:find('trunk()', 1, true) and jj.trunk_is_root(o) then
    vim.notify(
      ('trunk() resolves to root() (no remote bookmarks) — showing `::@` instead of `%s`'):format(revset),
      vim.log.levels.WARN,
      { title = 'jj-pickers' }
    )
    revset = '::@'
  end
  local bookmark = jj.bookmark(o)
  return {
    cwd = root,
    title = bookmark and (' ' .. bookmark) or 'jj revisions (no bookmark)',
    jj_root = root,
    jj_revset = revset,
    jj_limit = cfg.limit,
    jj_on_revision = cfg.on_revision,
  }
end

M.source = {
  finder = M.finder,
  format = M.format,
  preview = M.preview,
  confirm = M.confirm,
  sort = { fields = { 'score:desc', 'idx' } },
  layout = { preset = function() return vim.o.columns >= 120 and 'ivy' or 'vertical' end },
  toggles = { all = { icon = 'A', value = true } },
  config = function(opts)
    require('jj-pickers.highlights').setup()
    if opts.jj_root then return opts end
    local resolved = M.opts(require('jj-pickers.config').get())
    return resolved and vim.tbl_deep_extend('keep', opts, resolved) or opts
  end,
  actions = {
    jj_edit = function(picker, item) switch(picker, item, 'edit') end,
    jj_new = function(picker, item) switch(picker, item, 'new') end,
    jj_yank_change_id = { action = 'yank', field = 'change_id', reg = '+' },
    jj_changed_files = function(picker, item)
      if not item then return end
      picker:close()
      require('jj-pickers').changes { path = item.jj_root, revision = item.change_id }
    end,
  },
  win = {
    input = {
      keys = {
        ['<c-e>'] = { 'jj_edit', mode = { 'n', 'i' } },
        ['<a-n>'] = { 'jj_new', mode = { 'n', 'i' } },
        ['<c-l>'] = { 'jj_changed_files', mode = { 'n', 'i' } },
        ['<c-y>'] = { 'jj_yank_change_id', mode = { 'n', 'i' } },
        ['<a-a>'] = { 'toggle_all', mode = { 'n', 'i' } },
      },
    },
    list = {
      keys = {
        ['<c-e>'] = 'jj_edit',
        ['<a-n>'] = 'jj_new',
        ['<c-l>'] = 'jj_changed_files',
        ['<c-y>'] = 'jj_yank_change_id',
      },
    },
  },
}

return M
