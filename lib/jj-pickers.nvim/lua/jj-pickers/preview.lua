local M = {}

-- snacks' fancy renderer draws each hunk header as a three-line box:
--   ───────┐
--         │
--   ───────┘
-- jj's @@ headers carry no function-context text, so the middle line is usually just the
-- icon and the box is three lines of decoration per hunk. `hunk_header = false` would drop
-- the separator entirely and is not reachable through preview.cmd anyway, so collapse the
-- box to its single content line instead.
local function compact_hunk_headers(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  local modifiable = vim.bo[buf].modifiable
  vim.bo[buf].modifiable = true
  -- Deleted line by line, in reverse: replacing the whole buffer would drop the extmarks
  -- carrying the syntax highlighting. Box glyphs are multi-byte, so `─+` in a Lua pattern
  -- would repeat only that character's final byte — strip them out and compare instead.
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i = #lines, 1, -1 do
    local line = lines[i]
    local corner = vim.trim((line:gsub('─', '')))
    if corner == '┐' or corner == '┘' then
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, {})
    elseif vim.trim(line):sub(-3) == '│' then
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { (line:gsub('%s*│%s*$', '')) })
    end
  end
  vim.bo[buf].modifiable = modifiable
end

-- SnacksDiffContext carries a background, so every unchanged line in the diff gets tinted.
-- Remapped per-window rather than redefined, so this stays scoped to jj-pickers' previews
-- and leaves snacks' own git pickers alone.
local function quiet_context(win)
  if not (win and vim.api.nvim_win_is_valid(win)) then return end
  local cur = vim.wo[win].winhighlight or ''
  if cur:find('SnacksDiffContext:', 1, true) then return end
  vim.wo[win].winhighlight = (cur ~= '' and cur .. ',' or '') .. 'SnacksDiffContext:NormalFloat'
end

-- A diff carries no leading unchanged content, so the first hunk is always near the top and
-- `context` is what supplies the surrounding code. This drops the cursor on the first changed
-- line so it lands mid-pane rather than in the upper third.
--
-- The fancy renderer strips the +/- markers from the buffer text and carries them as
-- SnacksDiffAdd/SnacksDiffDelete extmarks, so the extmark scan is the reliable signal there;
-- the text scan is the fallback for `syntax` style, where the raw diff survives.
local function center_first_change(buf, win)
  if not (buf and win and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win)) then return end
  local target
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
    local hl = m[4] and m[4].hl_group
    if hl == 'SnacksDiffAdd' or hl == 'SnacksDiffDelete' then
      target = m[2] + 1
      break
    end
  end
  if not target then
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 500, false)) do
      if line:match '^[+-]' and not line:match '^[+-][+-][+-]' then
        target = i
        break
      end
    end
  end
  if not target then return end
  pcall(vim.api.nvim_win_set_cursor, win, { math.min(target, vim.api.nvim_buf_line_count(buf)), 0 })
  pcall(vim.api.nvim_win_call, win, function() vim.cmd 'normal! zz' end)
end

---@param ctx snacks.picker.preview.ctx
---@param cmd string[]
---@param opts { ft: string, cwd: string, title: string, center?: boolean }
function M.diff(ctx, cmd, opts)
  ctx.preview:set_title(opts.title)
  return require('snacks.picker.preview').cmd(cmd, ctx, {
    ft = opts.ft,
    cwd = opts.cwd,
    on_exit = function()
      local buf = ctx.buf
      local win = ctx.preview.win and ctx.preview.win.win
      vim.schedule(function()
        compact_hunk_headers(buf)
        quiet_context(win)
        if opts.center then center_first_change(buf, win) end
      end)
    end,
  })
end

return M
