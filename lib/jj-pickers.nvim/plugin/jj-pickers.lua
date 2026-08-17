if vim.g.loaded_jj_pickers then return end
vim.g.loaded_jj_pickers = true

vim.api.nvim_create_user_command(
  'JjChanges',
  function(cmd) require('jj-pickers').changes { revision = cmd.args ~= '' and cmd.args or nil } end,
  { nargs = '*', desc = 'jj-pickers: files changed in a revision (default @)' }
)

vim.api.nvim_create_user_command(
  'JjRevisions',
  function(cmd) require('jj-pickers').revisions { revset = cmd.args ~= '' and cmd.args or nil } end,
  { nargs = '*', desc = 'jj-pickers: revisions matching a revset (default trunk()..@)' }
)
