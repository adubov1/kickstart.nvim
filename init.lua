vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Options
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.expandtab = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
vim.o.termguicolors = true

-- Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('i', 'jk', '<ESC>')
vim.keymap.set('i', 'Jk', '<ESC>')
vim.keymap.set('i', 'JK', '<ESC>')
vim.keymap.set('n', '<leader>l', '<CMD>Lazy<CR>')

vim.keymap.set('n', '<leader>bd', '<CMD>bdelete<CR>')
vim.keymap.set('n', '<leader>bD', '<CMD>%bdelete<CR>')

vim.keymap.set('n', '<leader>v', '<CMD>vsp<CR>')
vim.keymap.set('n', '<leader>H', '<CMD>sp<CR>')

vim.keymap.set('n', '<leader>w', '<CMD>write<CR>')
vim.keymap.set('n', '<leader>q', '<CMD>bdelete<CR>')
vim.keymap.set('n', '<M-q>', '<CMD>qall<CR>')

vim.keymap.set('x', '>', '>gv')
vim.keymap.set('x', '<', '<gv')

-- Neovide
if vim.g.neovide then
  vim.keymap.set('n', '<D-s>', ':w<CR>')
  vim.keymap.set('v', '<D-c>', '"+y')
  vim.keymap.set('n', '<D-v>', '"+P')
  vim.keymap.set('v', '<D-v>', '"+P')
  vim.keymap.set('c', '<D-v>', '<C-R>+')
  vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli')

  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set('n', '<C-=>', function()
    change_scale_factor(1.1)
  end)
  vim.keymap.set('n', '<C-->', function()
    change_scale_factor(1 / 1.1)
  end)

  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

  local original_scroll_animation_length = 0.3
  local original_scroll_animation_far_lines = 1

  vim.api.nvim_create_autocmd('User', {
    pattern = 'TelescopeFindPre',
    callback = function()
      original_scroll_animation_length = vim.g.neovide_scroll_animation_length or 0.3
      original_scroll_animation_far_lines = vim.g.neovide_scroll_animation_far_lines or 1
      vim.g.neovide_scroll_animation_length = 0
      vim.g.neovide_scroll_animation_far_lines = 0
    end,
  })

  vim.api.nvim_create_autocmd('WinLeave', {
    callback = function()
      local filetype = vim.bo.filetype
      if filetype == 'TelescopePrompt' or filetype == 'TelescopeResults' then
        vim.defer_fn(function()
          vim.g.neovide_scroll_animation_length = original_scroll_animation_length
          vim.g.neovide_scroll_animation_far_lines = original_scroll_animation_far_lines
        end, 50)
      end
    end,
  })
end

vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
