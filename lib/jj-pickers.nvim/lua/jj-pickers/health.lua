local M = {}

local health = vim.health

local function check_nvim()
  health.start 'jj-pickers: neovim'
  local v = vim.version()
  local s = ('%d.%d.%d'):format(v.major, v.minor, v.patch)
  if vim.fn.has 'nvim-0.10' == 1 then
    health.ok('neovim ' .. s)
  else
    health.error('neovim ' .. s .. ' is too old', { 'jj-pickers needs 0.10 for vim.system, vim.fs.root and vim.uv.' })
  end
end

local function check_jj()
  health.start 'jj-pickers: jujutsu'
  local exe = vim.fn.exepath 'jj'
  if exe == '' then
    health.error('`jj` not found on $PATH', { 'https://jj-vcs.github.io/jj/latest/install-and-setup/' })
    return
  end
  local res = require('jj-pickers.jj').exec { '--version' }
  if res.ok then
    health.ok(('%s  (%s)'):format(exe, vim.trim(res.stdout)))
  else
    health.error(('%s exists but `jj --version` failed (exit %d)'):format(exe, res.code), { vim.trim(res.stderr) })
  end
end

local function check_snacks()
  health.start 'jj-pickers: snacks.nvim'
  if not (rawget(_G, 'Snacks') and Snacks.picker) then
    health.error('snacks.nvim picker is not available', { 'Install folke/snacks.nvim with `picker = { enabled = true }`.' })
    return
  end
  health.ok 'snacks.nvim picker loaded'
  for _, name in ipairs { 'jj_changes', 'jj_revisions' } do
    local ok, src = pcall(function() return Snacks.picker.sources[name] end)
    if ok and src then
      health.ok(('source registered: Snacks.picker.%s()'):format(name))
    else
      health.warn(('source %s is not registered'):format(name), {
        "require('jj-pickers').setup{} has not run yet, or a picker has not been opened.",
        'The pickers still work via require("jj-pickers").changes() / .revisions().',
      })
    end
  end
end

local function check_repo()
  health.start 'jj-pickers: repository'
  local jj = require 'jj-pickers.jj'
  local root = jj.root()
  if not root then
    health.info(('no .jj found above %s — open a file in a jj repo and re-run'):format(vim.fn.fnamemodify(vim.uv.cwd() or '.', ':~')))
    return
  end
  health.ok('workspace root: ' .. vim.fn.fnamemodify(root, ':~'))
  health.info(vim.uv.fs_stat(root .. '/.git') and 'colocated with git (.git present)' or 'jj-only (no .git)')

  local o = { root = root, stale = true }
  if jj.trunk_is_root(o) then
    health.warn('trunk() resolves to root() — this repo has no remote bookmarks', {
      'The default revset trunk()..@ would mean the entire history.',
      'jj-pickers substitutes `::@` and warns when you open the revisions picker.',
    })
  else
    health.ok 'trunk() resolves to a real commit'
  end

  health.info('nearest bookmark reachable from @: ' .. (jj.bookmark(o) or 'none'))

  local cfg = require('jj-pickers.config').get()
  health.info(('`%s` -n %d matches %d revision(s)'):format(cfg.revset, cfg.limit, #jj.lines(jj.log_args(o, cfg.revset, cfg.limit))))
  health.info(('`jj diff -r %s` lists %d changed file(s)'):format(cfg.revision, #jj.lines(jj.diff_args({ root = root }, cfg.revision))))
end

local function check_config()
  health.start 'jj-pickers: config'
  local cfg = require('jj-pickers.config').get()
  health.info(('revset=%q limit=%d revision=%q on_revision=%q context=%d'):format(cfg.revset, cfg.limit, cfg.revision, cfg.on_revision, cfg.context))
  if cfg.keys then
    for name, lhs in pairs(cfg.keys) do
      health.info(('keymap %s -> %s'):format(lhs, name))
    end
  else
    health.info 'keys = nil — plugin installs no keymaps (:JjChanges / :JjRevisions always exist)'
  end
end

function M.check()
  check_nvim()
  check_jj()
  check_snacks()
  check_repo()
  check_config()
end

return M
