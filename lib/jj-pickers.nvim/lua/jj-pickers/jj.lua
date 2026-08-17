local M = {}

M.timeout = 2000

M.templates = {
  -- 10 tab-separated columns; sources/revisions.lua parses them positionally.
  revision = table.concat({
    [[change_id.shortest(4)]],
    [[change_id.short(8)]],
    [[commit_id.short(8)]],
    [[if(current_working_copy, "1", "")]],
    [[if(immutable, "1", "")]],
    [[if(conflict, "1", "")]],
    [[if(empty, "1", "")]],
    [[local_bookmarks.join(",")]],
    [[author.timestamp().ago()]],
    [[if(description, description.first_line(), "")]],
  }, [[ ++ "\t" ++ ]]) .. [[ ++ "\n"]],

  file = [[status_char ++ "\t" ++ path ++ "\t" ++ path.absolute() ++ "\n"]],

  show_header = table.concat({
    [["commit " ++ commit_id ++ "\n"]],
    [["Change: " ++ change_id ++ "\n"]],
    [[if(local_bookmarks, "Bookmarks: " ++ local_bookmarks.join(", ") ++ "\n", "")]],
    [[if(conflict, "Conflict: yes\n", "")]],
    [["Author: " ++ author.name() ++ " <" ++ author.email() ++ ">\n"]],
    [["Date: " ++ author.timestamp().local().format("%Y-%m-%d %H:%M") ++ "\n\n"]],
    [[indent("    ", if(description, description, "(no description set)"))]],
    [["\n"]],
  }, ' ++ '),

  is_root = [[if(root, "root", "ok")]],
  bookmark = [[local_bookmarks.join(",") ++ "\n"]],
}

local function notify(msg, level) vim.notify(msg, level, { title = 'jj-pickers' }) end

function M.supported() return vim.fn.has 'nvim-0.10' == 1 end

function M.installed() return vim.fn.executable 'jj' == 1 end

local cache = {}

function M.root(path)
  local candidates = {}
  if path and path ~= '' then table.insert(candidates, path) end
  local buf = vim.api.nvim_buf_get_name(0)
  if buf ~= '' then table.insert(candidates, buf) end
  table.insert(candidates, vim.uv.cwd() or '.')
  for _, candidate in ipairs(candidates) do
    local dir = vim.fn.isdirectory(candidate) == 1 and candidate or vim.fs.dirname(candidate)
    if cache[dir] then return cache[dir] end
    local root = vim.fs.root(dir, { '.jj' })
    if root then
      cache[dir] = root
      return root
    end
  end
  return nil
end

function M.guard(path)
  if not M.supported() then
    notify('jj-pickers needs Neovim 0.10 or newer (vim.system, vim.fs.root)', vim.log.levels.ERROR)
    return nil
  end
  if not M.installed() then
    notify('`jj` is not on $PATH — https://jj-vcs.github.io/jj/latest/install-and-setup/', vim.log.levels.ERROR)
    return nil
  end
  local root = M.root(path)
  if not root then
    notify(('no .jj directory above %s — not a Jujutsu repo'):format(vim.fn.fnamemodify(path or vim.uv.cwd() or '.', ':~')), vim.log.levels.WARN)
    return nil
  end
  return root
end

-- Not optional: a user config may set `ui.color = "always"` (ANSI escapes even when piped)
-- and `ui.pager` (jj would block forever inside vim.system), and a repo with a conflicted
-- bookmark prepends Warning:/Hint: lines.
function M.flags(o)
  local args = { '-R', o.root, '--color=never', '--no-pager', '--quiet' }
  if o.stale then table.insert(args, '--ignore-working-copy') end
  return args
end

function M.args(o, extra)
  local args = M.flags(o)
  vim.list_extend(args, extra)
  return args
end

function M.cmd(args)
  local cmd = { 'jj' }
  vim.list_extend(cmd, args)
  return cmd
end

local function fileset(path) return ('root:"%s"'):format((path:gsub('[\\"]', '\\%0'))) end

function M.log_args(o, revset, limit)
  local extra = { 'log', '-r', revset, '--no-graph', '-T', M.templates.revision }
  if limit then
    table.insert(extra, 2, tostring(limit))
    table.insert(extra, 2, '-n')
  end
  return M.args(o, extra)
end

function M.diff_args(o, revision) return M.args(o, { 'diff', '-r', revision, '-T', M.templates.file }) end

function M.file_diff_args(o, revision, path, context) return M.args(o, { 'diff', '-r', revision, '--git', '--context', tostring(context or 12), fileset(path) }) end

function M.show_args(o, revision) return M.args(o, { 'show', '-r', revision, '--git', '-T', M.templates.show_header }) end

function M.switch_args(o, verb, change_id)
  if verb == 'new' then return M.args(o, { 'new', change_id }) end
  return M.args(o, { 'edit', '-r', change_id })
end

function M.exec(args)
  local ok, res = pcall(function() return vim.system(M.cmd(args), { text = true }):wait(M.timeout) end)
  if not ok then return { ok = false, code = -1, stdout = '', stderr = tostring(res) } end
  return { ok = res.code == 0, code = res.code, stdout = res.stdout or '', stderr = res.stderr or '' }
end

function M.lines(args)
  local res = M.exec(args)
  if not res.ok then return {} end
  return vim.split(vim.trim(res.stdout), '\n', { trimempty = true })
end

-- trunk() silently falls back to root() with no remote bookmarks, which would turn
-- `trunk()..@` into the entire history. A non-zero exit counts as degenerate too:
-- guessing small is recoverable, guessing large is not.
function M.trunk_is_root(o)
  local res = M.exec(M.args(o, { 'log', '-r', 'trunk()', '--no-graph', '-T', M.templates.is_root }))
  return not res.ok or vim.trim(res.stdout) == 'root'
end

function M.bookmark(o)
  local lines = M.lines(M.args(o, { 'log', '-r', 'heads(::@ & bookmarks())', '--no-graph', '-T', M.templates.bookmark }))
  local name = lines[1]
  if not name or name == '' then return nil end
  return name
end

function M.first_hunk_line(o, revision, path)
  local res = M.exec(M.file_diff_args(o, revision, path, 0))
  if not res.ok then return nil end
  local line = res.stdout:match '\n@@ %-%d+,?%d* %+(%d+)'
  return line and tonumber(line) or nil
end

return M
