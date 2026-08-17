return {
  'adubov1/jj-pickers.nvim',
  dir = vim.fn.stdpath 'config' .. '/lib/jj-pickers.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cmd = { 'JjChanges', 'JjRevisions' },
  keys = {
    { '<leader>jj', function() require('jj-pickers').changes() end, desc = 'jj changed files in @' },
    { '<leader>jl', function() require('jj-pickers').revisions() end, desc = 'jj revisions on branch' },
  },
  opts = {},
}
